csvData <- read.csv(file="data/block_latency-hysto.csv", head=TRUE, sep=",")
pdf("plots/hystos.pdf")
par(mfrow=c(3,3))

GB <- 10^9
cols <- c("green","yellow","blue","red")

# convert factor columns to numeric
toNumeric <- function(col){
    return(as.numeric(as.character(col)))
}

# exclude the data which we don't care
data <- subset(csvData, exclude_tag == "excluded:ok" & while_open_tag == "while_open:none" & block_size_tag == "bigblock")
late_stuck <- subset(data, latency_tag == 'latency:late')
early_stuck <- subset(data, latency_tag == 'latency:early')
early_n_late_stuck <- subset(data, latency_tag == 'latency:late:early')

#Total Plots
mytable <- aggregate(data$count,FUN=sum, by=list(data$data_type_tag))
barplot(mytable$x,names.arg=mytable$Group.1,main="Total - Data Type",col=cols[1], las=2)

mytable <- aggregate(data$count,FUN=sum, by=list(data$transfer_type_tag))
barplot(mytable$x,names.arg=mytable$Group.1,main="Total - Transfer Type",col=cols[2], las=2)

mytable <- aggregate(data$count,FUN=sum, by=list(data$tiers_tag))
barplot(mytable$x,names.arg=mytable$Group.1,main="Total - Tier Type",col=cols[3], las=2)

# Late Stuck Plots

mytable <- aggregate(late_stuck$count,FUN=sum, by=list(late_stuck$data_type_tag))
barplot(mytable$x,names.arg=mytable$Group.1,main="Late Stuck - Data Type",col=cols[1], las=2)

mytable <- aggregate(late_stuck$count,FUN=sum, by=list(late_stuck$transfer_type_tag))
barplot(mytable$x,names.arg=mytable$Group.1,main="Late Stuck - Transfer Type",col=cols[2], las=2)

mytable <- aggregate(late_stuck$count,FUN=sum, by=list(late_stuck$tiers_tag))
barplot(mytable$x,names.arg=mytable$Group.1,main="Late Stuck - Tier Type",col=cols[3], las=2)


# Early Stuck Plots

mytable <- aggregate(early_stuck$count,FUN=sum, by=list(early_stuck$data_type_tag))
barplot(mytable$x,names.arg=mytable$Group.1,main="Early Stuck - Data Type",col=cols[1], las=2)

mytable <- aggregate(early_stuck$count,FUN=sum, by=list(early_stuck$transfer_type_tag))
barplot(mytable$x,names.arg=mytable$Group.1,main="Early Stuck - Transfer Type",col=cols[2], las=2)


mytable <- aggregate(early_stuck$count,FUN=sum, by=list(early_stuck$tiers_tag))
barplot(mytable$x,names.arg=mytable$Group.1,main="Early Stuck - Tier Type",col=cols[3], las=2)


# Early & Late Stuck Plots

mytable <- aggregate(early_n_late_stuck$count,FUN=sum, by=list(early_n_late_stuck$data_type_tag))
barplot(mytable$x,names.arg=mytable$Group.1,main="Early & Late Stuck - Data Type",col=cols[1], las=2)

mytable <- aggregate(early_n_late_stuck$count,FUN=sum, by=list(early_n_late_stuck$transfer_type_tag))
barplot(mytable$x,names.arg=mytable$Group.1,main="Early & Late Stuck - Transfer Type",col=cols[2], las=2)

mytable <- aggregate(early_n_late_stuck$count,FUN=sum, by=list(early_n_late_stuck$tiers_tag))
barplot(mytable$x,names.arg=mytable$Group.1,main="Early & Late Stuck - Tier Type",col=cols[3], las=2)

#Total Latency Count
mytable <- aggregate(data$count,FUN=sum, by=list(data$latency_tag))
barplot(mytable$x,names.arg=mytable$Group.1,main="Latency Type",col=cols[4], las=2)


dev.off()
