par(mfrow=c(2,3))
hist(log10(block.latency$skew5_100[sel.lClass.stuck]))
hist(log10(block.latency$skew5_95[sel.lClass.stuck]))
hist(log10(block.latency$skew5_75[sel.lClass.stuck]))
hist(log10(block.latency$skew5_50[sel.lClass.stuck]))
hist(log10(block.latency$skew5_25[sel.lClass.stuck]))

