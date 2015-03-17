csvData <- read.csv(file="block_latency-tagged.csv", head=TRUE, sep=",")
pdf("plots.pdf")
par(mfrow=c(2,2))

GB <- 10^9
cols <- c("yellow","green","blue","red")
# limits which will be used while classifying the input data
LIMIT_STUCK_EARLY <- 10*3600
LIMIT_STUCK_LATE <- 5*3600
LIMIT_SIZE <- 500*GB

# average transfer rate which will be used to add some offset while getting the tails
AVERAGE_TRANSFER_RATE <- 10^7 #10MB/s

# convert factor columns to numeric
toNumeric <- function(col){
    #return(as.numeric(levels(col))[col])
    return(as.numeric(as.character(col)))
}

# to see the plot cleaner, only show skews between [SKEW_LIMIT_MIN, SKEW_LIMIT_MAX]
# number of values outside of the range will be printed at plot's topright
SKEW_LIMIT_MIN <- 0
SKEW_LIMIT_MAX <- 8
SKEW_INCREMENT <- 0.1
drawSkew <- function(skewList, title, label, color){
	skew <- skewList[skewList>=SKEW_LIMIT_MIN & skewList<=SKEW_LIMIT_MAX]
	hist(skew,main=paste(title,' - Skew Plot'), xlab=label, breaks=seq(from=SKEW_LIMIT_MIN, to=SKEW_LIMIT_MAX, by=SKEW_INCREMENT), col=color)
	legend("topright", c(paste("# >",SKEW_LIMIT_MAX,": ", length(skewList[skewList > SKEW_LIMIT_MAX])),paste("# <",SKEW_LIMIT_MIN, ": ", length(skewList[skewList < SKEW_LIMIT_MIN]))), cex=0.7, bty="n")
}

drawAllSkews <- function(data, title, color){
	drawSkew(data$skew_25, title, "skew_25", color)
	drawSkew(data$skew_50, title, "skew_50", color)
	drawSkew(data$skew_75, title, "skew_75", color)
	drawSkew(data$skew_95, title, "skew_95", color)
	
	drawSkew(data$rskew_25, title, "rskew_25", color)
	drawSkew(data$rskew_50, title, "rskew_50", color)
	drawSkew(data$rskew_75, title, "rskew_75", color)
	drawSkew(data$rskew_95, title, "rskew_95", color)
	
	drawSkew(data$skew_last_5, title, "skew_last_5", color)
	drawSkew(data$skew_last_25, title, "skew_last_25", color)
	drawSkew(data$skew_last_50, title, "skew_last_50", color)
	drawSkew(data$skew_last_75, title, "skew_last_75", color)
	
	drawSkew(data$rskew_last_5, title, "rskew_last_5", color)
	drawSkew(data$rskew_last_25, title, "rskew_last_25", color)
	drawSkew(data$rskew_last_50, title, "rskew_last_50", color)
	drawSkew(data$rskew_last_75, title, "rskew_last_75", color)
}



# exclude the data which we don't care
data <- subset(csvData, exclude_tag == "excluded:ok" & while_open_tag == "while_open:none" & bytes > LIMIT_SIZE)

# cast factors to numerics
data$skew_25 <- toNumeric(data$skew_25)
data$skew_50 <- toNumeric(data$skew_50)
data$skew_75 <- toNumeric(data$skew_75)
data$skew_95 <- toNumeric(data$skew_95)
data$rskew_25 <- toNumeric(data$rskew_25)
data$rskew_50 <- toNumeric(data$rskew_50)
data$rskew_75 <- toNumeric(data$rskew_75)
data$rskew_95 <- toNumeric(data$rskew_95)
data$skew_last_5 <- toNumeric(data$skew_last_5)
data$skew_last_25 <- toNumeric(data$skew_last_25)
data$skew_last_50 <- toNumeric(data$skew_last_50)
data$skew_last_75 <- toNumeric(data$skew_last_75)
data$rskew_last_5 <- toNumeric(data$rskew_last_5)
data$rskew_last_25 <- toNumeric(data$rskew_last_25)
data$rskew_last_50 <- toNumeric(data$rskew_last_50)
data$rskew_last_75 <- toNumeric(data$rskew_last_75)

# classify data into groups
stuckEarly  <- subset(data, first_replica_delta > LIMIT_STUCK_EARLY) 
stuckLate   <- subset(data, last_replica - percent95_replica >  LIMIT_STUCK_LATE+(bytes/20)/AVERAGE_TRANSFER_RATE)
stuckOthers <- subset(data, last_replica - percent95_replica <= LIMIT_STUCK_LATE+(bytes/20)/AVERAGE_TRANSFER_RATE & first_replica_delta <= LIMIT_STUCK_EARLY)

# print # of data
paste("# of data left: ", nrow(data))
paste("# of early stacks: ", nrow(stuckEarly))
paste("# of tails: ", nrow(stuckLate))
paste("# of others: ", nrow(stuckOthers))

# plot for all transfers by groups above
lbls <- c("Early Stuck", "Tails", "Others")
slices <- c(nrow(stuckEarly), nrow(stuckLate), nrow(stuckOthers))
barplot(slices, names.arg = lbls, cex.names=0.8, main="Where transfers got stuck", col = cols, horiz=TRUE)

# plots by Data Type
barplot(table(stuckEarly$data_type_tag), main="Early Stuck - Data Type", col=cols[1])
barplot(table(stuckLate$data_type_tag), main="Tails - Data Type", col=cols[2])
barplot(table(stuckOthers$data_type_tag), main="Others - Data Type", col=cols[3])

# plots by Transfer Type
barplot(table(stuckEarly$transfer_type_tag), main="Early Stuck - Transfer Type", col=cols[1])
barplot(table(stuckLate$transfer_type_tag), main="Tails - Transfer Type", col=cols[2])
barplot(table(stuckOthers$transfer_type_tag), main="Others - Transfer Type", col=cols[3])

plot.new()

# skew variables
drawAllSkews(data, "Data", cols[4])

drawAllSkews(stuckEarly, "Early Stuck", cols[1])
drawAllSkews(stuckLate, "Tails", cols[2])
drawAllSkews(stuckOthers, "Others", cols[3])

dev.off()
