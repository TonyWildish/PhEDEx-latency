csvData <- read.csv(file="../block_latency-tagged.csv", head=TRUE, sep=",")
pdf("tails.pdf")
par(mfrow=c(2,2))

GB <- 10^9
cols <- c("green","yellow","blue","red")

# limits which will be used while classifying the input data
LIMIT_STUCK_EARLY <- 10*3600
LIMIT_STUCK_LATE <- 10*3600
LIMIT_SIZE <- 300*GB

# average transfer rate which will be used to add some offset while getting the tails
AVERAGE_TRANSFER_RATE <- 5*10^6 #5MB/s

# convert factor columns to numeric
toNumeric <- function(col){
    return(as.numeric(as.character(col)))
}

# to see the plot cleaner, only show skews between [SKEW_LIMIT_MIN, SKEW_LIMIT_MAX]
# number of values outside of the range will be printed at plot's topright
SKEW_LIMIT_MIN <- 0
SKEW_LIMIT_MAX <- 8
SKEW_INCREMENT <- 0.2
drawSkew <- function(skewList, title, label, color){
	# get skews in the range and plot
	skew <- skewList[skewList>=SKEW_LIMIT_MIN & skewList<=SKEW_LIMIT_MAX]
	hist(skew,main=paste(title,' - Skew Plot'), xlab=label, breaks=seq(from=SKEW_LIMIT_MIN, to=SKEW_LIMIT_MAX, by=SKEW_INCREMENT), col=color)
	# print number of skews not in the range
	legend("topright", c(paste("# >",SKEW_LIMIT_MAX,": ", length(skewList[skewList > SKEW_LIMIT_MAX])),paste("# <",SKEW_LIMIT_MIN, ": ", length(skewList[skewList < SKEW_LIMIT_MIN]))), cex=0.7, bty="n")
}


# exclude the data which we don't care
data <- subset(csvData, exclude_tag == "excluded:ok" & while_open_tag == "while_open:none" & bytes > LIMIT_SIZE)

# cast factors to numerics
data$skew_95 <- toNumeric(data$skew_95)
data$rskew_95 <- toNumeric(data$rskew_95)
data$rskew_last_5 <- toNumeric(data$rskew_last_5)

# get tails
stuckTails <- subset(data, last_replica - percent95_replica > LIMIT_STUCK_LATE + (bytes/20)/AVERAGE_TRANSFER_RATE)

# print # of data
paste("# of data: ", nrow(data))
paste("# of tails including early stucks: ", nrow(stuckTails))

# exclude early stucks from the list
stuckTails <- subset(stuckTails, first_replica_delta < LIMIT_STUCK_EARLY + avg_file_size/AVERAGE_TRANSFER_RATE)
paste("# of tails: ", nrow(stuckTails))


# col: color
# las=2: show all x labels
# plots by Data Type
###png(file = "tails_datatype.png")
barplot(table(stuckTails$data_type_tag), main="Tails - Data Type", col=cols[1], las=2)
###dev.off()

# plots by Transfer Type
###png(file = "tails_transfertype.png")
barplot(table(stuckTails$transfer_type_tag), main="Tails - Transfer Type", col=cols[2], las=2)
###dev.off()

# plot by Tier src->dst
###png(file = "tails_tiertype.png")
stuckTails$tier <- paste(stuckTails$src_tier, stuckTails$dst_tier, sep="->")
barplot(table(stuckTails$tier), main="Tails - Tier Type", col=cols[3], las=2)
###dev.off()

# draw an empty placeholder plot 
plot.new()

###png(file = "tails_skew1.png")
drawSkew(stuckTails$skew_95, "Tails", "skew_95", cols[4])
###dev.off()
###png(file = "tails_skew2.png")
drawSkew(stuckTails$rskew_last_5, "Tails", "rskew_last_5", cols[4])
###dev.off()

# put some limit to the x axis in order to prevent that it goes to too high values
LIMIT <- 200
exceed <- nrow(subset (stuckTails, skew_95 > LIMIT))
###png(file = "tails_skew_scatter1.png")
plot(stuckTails$skew_95,stuckTails$rskew_last_5, main="Skew", xlim=c(0,LIMIT), xlab="skew_95", ylab="rskew_last_5", col=rgb(0,100,0,50,maxColorValue=255), pch=16)
legend("topright", paste("#exceed:",exceed), cex=0.7, bty="n")
###dev.off()
###png(file = "tails_skew_scatter2.png")
plot(stuckTails$skew_95,stuckTails$rskew_95, main="Skew", xlim=c(0,LIMIT), xlab="skew_95", ylab="rskew_95", col=rgb(0,100,0,50,maxColorValue=255), pch=16)
legend("topright", paste("#exceed:",exceed), cex=0.7, bty="n")
###dev.off()

dev.off()
