csvData <- read.csv(file="data/block_latency-tagged.csv", head=TRUE, sep=",")
pdf("transf_population.pdf")
par(mfrow=c(2,2))

GB <- 10^9
cols <- c("green","yellow","blue","red")

# limits which will be used while classifying the input data
LIMIT_STUCK_EARLY <- 10*3600
LIMIT_STUCK_LATE <- 10*3600
LIMIT_SIZE <- 500*GB

# average transfer rate which will be used to add some offset while getting the tails
AVERAGE_TRANSFER_RATE <- 5*10^6 #5MB/s

# convert factor columns to numeric
toNumeric <- function(col){
    return(as.numeric(as.character(col)))
}

# exclude the data which we don't care
data <- subset(csvData, exclude_tag == "excluded:ok" & while_open_tag == "while_open:none" & bytes > LIMIT_SIZE)

#Get Tails
stuckTails <- subset(data, last_replica - percent95_replica > LIMIT_STUCK_LATE + (bytes/20)/AVERAGE_TRANSFER_RATE)

# exclude early stucks from the list
stuckTails <- subset(stuckTails, first_replica_delta < LIMIT_STUCK_EARLY + avg_file_size/AVERAGE_TRANSFER_RATE)


# plots by Data Type
barplot(table(data$data_type_tag), main="Total - Data Type", col=cols[1], las=2)

barplot(table(stuckTails$data_type_tag), main="Tails - Data Type", col=cols[1], las=2)

# plots by Transfer Type
barplot(table(data$transfer_type_tag), main="Total - Transfer Type", col=cols[2], las=2)

barplot(table(stuckTails$transfer_type_tag), main="Tails - Transfer Type", col=cols[2], las=2)

# plot by Tier src->dst
data$tier <- paste(data$src_tier, stuckTails$dst_tier, sep="->")
barplot(table(data$tier), main="Total - Tier Type", col=cols[3], las=2)

stuckTails$tier <- paste(stuckTails$src_tier, stuckTails$dst_tier, sep="->")
barplot(table(stuckTails$tier), main="Tails - Tier Type", col=cols[3], las=2)

dev.off()
