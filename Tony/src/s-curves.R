startDev()
xLim <- range(c(0,1))
yLim <- range(c(0,100))
plot(0,0,xlim=xLim,ylim=yLim,type='n',
  xlab='fraction of transfer time',
  ylab='percent complete')

percentiles = c(0,25,50,75,95)
sCurve <- function(x) {
  xCoord <- c(0,
              x$dt.25pct,
              x$dt.50pct,
              x$dt.75pct,
              x$dt.95pct)
# lines(xCoord,percentiles,col=rgb(0.5,0.5,0.5,0.5))
  lines(xCoord,percentiles)
}
nplot <- nrow(bfilt)
nplot <- 500 # limit things a bit...
for (i in 1:nplot ) { sCurve(bfilt[i,]) }

# xLim <- range(0,1)
# yLim <- range(c(0,100))
# plot(0,0,xlim=xLim,ylim=yLim,type='n')
# sCurveNormal <- function(x) {
#   xCoord <- c(0,
#                    (x$dt.25pct/x$dt.last),
#                    (x$dt.50pct/x$dt.last),
#                    (x$dt.75pct/x$dt.last),
#                    (x$dt.95pct/x$dt.last),
#               1)
# # lines(xCoord,percentiles,col=rgb(0.5,0.5,0.5,0.5))
#   lines(xCoord,percentiles)
# }

# for (i in 1:nrow(b) ) { sCurveNormal(b[i,]) }
