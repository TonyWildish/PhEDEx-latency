# Exploratory skew properties
#startDev()

par(mfrow=c(2,2))
#hist(log10(bfilt$dt.25pct))
#hist(log10(bfilt$dt.50pct))
#hist(log10(bfilt$dt.75pct))
#hist(log10(bfilt$dt.95pct))

hist(bfilt$dt.25pct)
hist(bfilt$dt.50pct)
hist(bfilt$dt.75pct)
hist(bfilt$dt.95pct)
