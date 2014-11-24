par(mfrow=c(2,3))
hist(log10(bfilt$skew5_100[bfilt$classification == 'stuck']))
hist(log10(bfilt$skew5_95[bfilt$classification == 'stuck']))
hist(log10(bfilt$skew5_75[bfilt$classification == 'stuck']))
hist(log10(bfilt$skew5_50[bfilt$classification == 'stuck']))
hist(log10(bfilt$skew5_25[bfilt$classification == 'stuck']))

