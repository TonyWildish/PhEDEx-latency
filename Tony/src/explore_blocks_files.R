startDev()
par(mfrow=c(2,2), oma=c(1,0,2,0))
colour = 'blue'
smoothScatter(log10(bfilt$files) ~ log10(bfilt$bytes),
  cex=0.1,
  xlab='log10 bytes',
  ylab='log10 files'
  )
hist(log10(bfilt$files), col=colour, xlab='log10 files', main='')
hist(log10(bfilt$bytes), col=colour, xlab='log10 bytes', main='')
hist(log10(bfilt$bytes/bfilt$files), col=colour, xlab='log10 bytes/file average', main='')
mtext(text='All data', side=3, outer=TRUE, cex=1.5)
savePlot('graphs/bfilt-files-bytes.bmp')

smoothScatter(log10(bsel$files) ~ log10(bsel$bytes),
  cex=0.1,
  xlab='log10 bytes',
  ylab='log10 files'
  )
hist(log10(bsel$files), col=colour, xlab='log10 files', main='')
hist(log10(bsel$bytes), col=colour, xlab='log10 bytes', main='')
hist(log10(bsel$bytes/bsel$files), col=colour, xlab='log10 bytes/file average', main='')
mtext(text='Filtered subset', side=3, outer=TRUE, cex=1.5)
savePlot('graphs/bsel-files-bytes-1.bmp')

hist(bsel$files[bsel$files < 15], xlim=range(0,15), col=colour, xlab='files/block', main='')
hist(log10(bsel$bytes[bsel$files == 5]), col=colour, xlab='bytes/file for files/block = 5', main='')
plot(log10(bsel$files) ~ log10(bsel$bytes/bsel$files),
  col='blue',
  cex=0.2,
  xlab='log10 average file size',
  ylab='log10 files per block'
  )
plot(log10(bsel$bytes) ~ log10(bsel$bytes/bsel$files),
  col='blue',
  cex=0.2,
  xlab='log10 average file size',
  ylab='log10 bytes per block'
  )
mtext(text='Filtered subset', side=3, outer=TRUE, cex=1.5)
savePlot('graphs/bsel-files-bytes-2.bmp')
