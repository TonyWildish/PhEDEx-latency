csvData <- read.csv(file="input.csv", head=TRUE, sep=",")
#pdf("plots.pdf")
#par(mfrow=c(2,2))
GB <- 10^9
MB <- 10^6

# convert factor columns to numeric
toNumeric <- function(col){
    return(as.numeric(as.character(col)))
}

# exclude data which we don't care
data <- subset(csvData, exclude_tag == "excluded:ok" & while_open_tag == "while_open:none")

data$rskew_last_5 <- toNumeric(data$rskew_last_5)
data$skew_95 <- toNumeric(data$skew_95)
data$skew_25 <- toNumeric(data$skew_25)
data$skew_last_75 <- toNumeric(data$skew_last_75)


#
#EARLY STUCK#
#
earlyStuck <- subset(data, latency_tag == "latency:early")
paste("Early Stuck:", nrow(earlyStuck))

png(file = "early_skew.png", width = 6, height = 6, units ='in', res = 300, bg="transparent")
plot(earlyStuck$skew_last_75,earlyStuck$skew_25, main="", xlab="Skew Last 75", ylab="Skew 25", col=rgb(0,0,255,alpha=130,max=255), pch=16)
dev.off()

png(file = "early_rate.png", width = 6, height = 6, units ='in', res = 300, bg="transparent")
earlyStuck$rate0_25   <- ((earlyStuck$bytes/MB) * 0.25) / (earlyStuck$percent25_replica - earlyStuck$time_subscription)
earlyStuck$rate25_100 <- ((earlyStuck$bytes/MB) * 0.75) / (earlyStuck$last_replica      - earlyStuck$percent25_replica)
plot(earlyStuck$rate0_25,earlyStuck$rate25_100, main="", xlab="Rate 0-25% (MB/s)", ylab="Rate 25-100% (MB/s)", col=rgb(0,255,0,alpha=130,max=255), pch=16)
dev.off()

png(file = "early_first_replica.png", width = 6, height = 6, units ='in', res = 300, bg="transparent")
hist(subset(earlyStuck, first_replica_delta <= 360000)$first_replica_delta / 3600, xlab="Time spent for the first file transfer in hour", main="", breaks=seq(from=0, to=100, by=4), col="yellow")
dev.off()

#
#TAIL STUCK#
#
tailStuck  <- subset(data, latency_tag == "latency:late" & bytes > 300*GB)
paste("Tail Stuck:" , nrow(tailStuck))

png(file = "tail_skew.png", width = 6, height = 6, units ='in', res = 300, bg="transparent")
plot(tailStuck$skew_95,tailStuck$rskew_last_5, main="", xlab="Skew 95", ylab="Reverse Skew Last 5", col=rgb(0,0,255,alpha=130,max=255), pch=16)
dev.off()

tailStuck$rate0_95   <- ((tailStuck$bytes/MB) * 0.95) / (tailStuck$percent95_replica - tailStuck$time_subscription)
tailStuck$rate95_100 <- ((tailStuck$bytes/MB) * 0.05) / (tailStuck$last_replica      - tailStuck$percent95_replica)
png(file = "tail_rate.png", width = 6, height = 6, units ='in', res = 300, bg="transparent")
plot(tailStuck$rate0_95,tailStuck$rate95_100, main="", xlab="Rate 0-95% (MB/s)", ylab="Rate 95-100% (MB/s)", col=rgb(0,255,0,alpha=130,max=255), pch=16)
dev.off()

#dev.off()
