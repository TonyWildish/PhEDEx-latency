data <- read.csv(file="block_latency-processed.csv", head=TRUE, sep=",")
pdf("plots.pdf")
par(mfrow=c(2,2))

LIMIT_STUCK_EARLY <- 10*3600
LIMIT_STUCK_LATE <- 5*3600


# classify data into groups
stuckEarly <- subset(data, first_replica_delta > LIMIT_STUCK_EARLY) 
stuckLate <- subset(data, last_replica - percent95_replica > LIMIT_STUCK_LATE)
stuckOthers <- subset(data, last_replica - percent95_replica <= LIMIT_STUCK_LATE & first_replica_delta <= LIMIT_STUCK_EARLY)


# plot for all transfers by groups above
cols <- c("yellow","green","blue", "red")
lbls <- c("Early Stuck", "Late Stuck", "Others")
slices <- c(nrow(stuckEarly), nrow(stuckLate), nrow(stuckOthers))
barplot(slices, names.arg = lbls, cex.names=0.8, main="Where transfers got stuck", col = cols, horiz=TRUE)

# divide stuck transfers by data-tier
lbls <- c("T0", "T1", "T2", "T3")
slices <- c(nrow(stuckEarly[ which(stuckEarly$dst_tier==0), ]),
			nrow(stuckEarly[ which(stuckEarly$dst_tier==1), ]),
			nrow(stuckEarly[ which(stuckEarly$dst_tier==2), ]),
			nrow(stuckEarly[ which(stuckEarly$dst_tier==3), ]))
barplot(slices, names.arg = lbls, main="Early Stuck by Tier", col = cols, horiz=TRUE)
legend("topright", paste("Total: ", sum(slices)), cex=0.7, bty="n")

slices <- c(nrow(stuckLate[ which(stuckLate$dst_tier==0), ]),
			nrow(stuckLate[ which(stuckLate$dst_tier==1), ]),
			nrow(stuckLate[ which(stuckLate$dst_tier==2), ]),
			nrow(stuckLate[ which(stuckLate$dst_tier==3), ]))
barplot(slices, names.arg = lbls, main="Late Stuck by Tier", col = cols, horiz=TRUE)
legend("topright", paste("Total: ", sum(slices)), cex=0.7, bty="n")

slices <- c(nrow(stuckOthers[ which(stuckOthers$dst_tier==0), ]),
			nrow(stuckOthers[ which(stuckOthers$dst_tier==1), ]),
			nrow(stuckOthers[ which(stuckOthers$dst_tier==2), ]),
			nrow(stuckOthers[ which(stuckOthers$dst_tier==3), ]))
barplot(slices, names.arg = lbls, main="Others by Tier", col = cols, horiz=TRUE)
legend("topright", paste("Total: ", sum(slices)), cex=0.7, bty="n")


# divide stuck transfers by size
# divide each plot into to for the samples less than SIZE_LIMIT and greater than SIZE_LIMIT
SIZE <- 10^9
SIZE_STR <- "GB"
SIZE_LIMIT <- 500 * SIZE
SIZE_LIMIT_STR <- "500GB"
cols = "blue"

dataSmall <- subset(data, bytes<SIZE_LIMIT)
dataLarge <- subset(data, bytes>=SIZE_LIMIT)
hist(dataSmall$bytes/SIZE, main=paste("All data by Size <",SIZE_LIMIT_STR), xlab=paste("Size in ",SIZE_STR), col=cols)
legend("topright", paste("Total: ", nrow(dataSmall)), cex=0.7, bty="n")
hist(dataLarge$bytes/SIZE, main=paste("All data by Size >",SIZE_LIMIT_STR), xlab=paste("Size in ",SIZE_STR), col=cols)
legend("topright", paste("Total: ", nrow(dataLarge)), cex=0.7, bty="n")

stuckEarlySmall <- subset(stuckEarly, bytes<SIZE_LIMIT)
stuckEarlyLarge <- subset(stuckEarly, bytes>=SIZE_LIMIT)
hist(stuckEarlySmall$bytes/SIZE, main=paste("Early Stuck by Size <",SIZE_LIMIT_STR), xlab=paste("Size in ",SIZE_STR), col=cols)
legend("topright", paste("Total: ", nrow(stuckEarlySmall)), cex=0.7, bty="n")
hist(stuckEarlyLarge$bytes/SIZE, main=paste("Early Stuck by Size >",SIZE_LIMIT_STR), xlab=paste("Size in ",SIZE_STR), col=cols)
legend("topright", paste("Total: ", nrow(stuckEarlyLarge)), cex=0.7, bty="n")

stuckLateSmall <- subset(stuckLate, bytes<SIZE_LIMIT)
stuckLateLarge <- subset(stuckLate, bytes>=SIZE_LIMIT)
hist(stuckLateSmall$bytes/SIZE, main=paste("Late Stuck by Size <",SIZE_LIMIT_STR), xlab=paste("Size in ",SIZE_STR), col=cols)
legend("topright", paste("Total: ", nrow(stuckLateSmall)), cex=0.7, bty="n")
hist(stuckLateLarge$bytes/SIZE, main=paste("Late Stuck by Size >",SIZE_LIMIT_STR), xlab=paste("Size in ",SIZE_STR), col=cols)
legend("topright", paste("Total: ", nrow(stuckLateLarge)), cex=0.7, bty="n")

stuckOthersSmall <- subset(stuckOthers, bytes<SIZE_LIMIT)
stuckOthersLarge <- subset(stuckOthers, bytes>=SIZE_LIMIT)
hist(stuckOthersSmall$bytes/SIZE, main=paste("Others by Size <",SIZE_LIMIT_STR), xlab=paste("Size in ",SIZE_STR), col=cols)
legend("topright", paste("Total: ", nrow(stuckOthersSmall)), cex=0.7, bty="n")
hist(stuckOthersLarge$bytes/SIZE, main=paste("Others by Size >",SIZE_LIMIT_STR), xlab=paste("Size in ",SIZE_STR), col=cols)
legend("topright", paste("Total: ", nrow(stuckOthersLarge)), cex=0.7, bty="n")


# skew variables
SKEW_LIMIT_MIN <- 0
SKEW_LIMIT_MAX <- 4
SKEW_INCREMENT <- 0.05
cols = "green"
# remove infinite values, and values lower than SKEW_LIMIT_MIN, greater than SKEW_LIMIT_MAX
skew25 <- as.numeric(as.character(data$skew_25))
skew25 <- subset(skew25, !is.na(skew25) & skew25>=SKEW_LIMIT_MIN & skew25<=SKEW_LIMIT_MAX)
skew50 <- as.numeric(as.character(data$skew_50))
skew50 <- subset(skew50, !is.na(skew50) & skew50>=SKEW_LIMIT_MIN & skew50<=SKEW_LIMIT_MAX)
skew75 <- as.numeric(as.character(data$skew_75))
skew75 <- subset(skew75, !is.na(skew75) & skew75>=SKEW_LIMIT_MIN & skew75<=SKEW_LIMIT_MAX)
skew95 <- as.numeric(as.character(data$skew_95))
skew95 <- subset(skew95, !is.na(skew95) & skew95>=SKEW_LIMIT_MIN & skew95<=SKEW_LIMIT_MAX)

nrow(data)
nrow(subset(data, skew_95 == 0))
nrow(subset(data, percent95_replica == first_replica))

total <- nrow(data)
hist(skew25,main='Skew Plot', xlab='skew_25', breaks=seq(from=SKEW_LIMIT_MIN, to=SKEW_LIMIT_MAX, by=SKEW_INCREMENT), col=cols)
legend("topright", paste("# ignored: ", total-length(skew25)), cex=0.7, bty="n")
hist(skew50,main='Skew Plot', xlab='skew_50', breaks=seq(from=SKEW_LIMIT_MIN, to=SKEW_LIMIT_MAX, by=SKEW_INCREMENT), col=cols)
legend("topright", paste("# ignored: ", total-length(skew50)), cex=0.7, bty="n")
hist(skew75,main='Skew Plot', xlab='skew_75', breaks=seq(from=SKEW_LIMIT_MIN, to=SKEW_LIMIT_MAX, by=SKEW_INCREMENT), col=cols)
legend("topright", paste("# ignored: ", total-length(skew75)), cex=0.7, bty="n")
hist(skew95,main='Skew Plot', xlab='skew_95', breaks=seq(from=SKEW_LIMIT_MIN, to=SKEW_LIMIT_MAX, by=SKEW_INCREMENT), col=cols)
legend("topright", paste("# ignored: ", total-length(skew95)), cex=0.7, bty="n")


# calculate new skew variable:  (time spent to transfer 25% / time spent to transfer 100%) * (100 / 25)
data$skew = ((data$percent75_replica_delta - data$percent50_replica_delta) / data$last_replica_delta ) * 4.0
# ignore values infinite, NAs, or not in the ranges
skew <- subset(data, last_replica_delta == 0  | (!is.na(skew) & skew>=SKEW_LIMIT_MIN & skew<=SKEW_LIMIT_MAX))$skew
hist(skew,main='Skew Plot', xlab='skew_new', breaks=seq(from=SKEW_LIMIT_MIN, to=SKEW_LIMIT_MAX, by=SKEW_INCREMENT), col=cols)
legend("topright", paste("# ignored: ", total-length(skew)), cex=0.7, bty="n")


#last_replica_transfer_time <- data$last_replica - data$percent95_replica
#plot(testdata$skew,testdata$bytes/10^9, main="PDF Scatterplot Example", col=rgb(0,100,0,50,maxColorValue=255), pch=16)
#hist(stuckEarly$first_replica_delta, main="PDF Scatterplot Example", col=rgb(0,100,0,50,maxColorValue=255), pch=16)
# High Density Scatterplot with Binning
#plot(data$first_replica_delta,data$last_replica_transfer_time, main="PDF Scatterplot Example", col=rgb(0,100,0,50,maxColorValue=255), pch=16)
#plot(data$first_replica_delta,last_replica_transfer_time,main='', xlab='first replica', ylab='last replica')
#hist(dataByTier,main="Stuck Transfers at 0%",xlab="first replica delta", legend = rownames(counts))
#hist(last_replica_transfer_time,main="Stuck Transfers after 95%",xlab="last replica delta")
#barplot(data$first_replica_delta,main="Distribution of transfer start time",xlab="first replica delta",breaks=3600)
#hist(data$first_replica_delta,main="Distribution",xlab="first replica delta",breaks=3600)


dev.off()