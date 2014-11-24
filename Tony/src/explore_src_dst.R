# Exploratory plots of source and destination latencies
startDev()
devAskNewPage(ask=TRUE)
par(mfrow=c(3,1))
hist(log10(block.latency$dt.last[sel.src.T0]))
hist(log10(block.latency$dt.last[sel.src.T1]))
hist(log10(block.latency$dt.last[sel.src.T2]))

hist(log10(block.latency$dt.last[sel.dst.T0]))
hist(log10(block.latency$dt.last[sel.dst.T1]))
hist(log10(block.latency$dt.last[sel.dst.T2]))

