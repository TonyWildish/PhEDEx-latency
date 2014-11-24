startDev()
xLim <- range(log10(max(b$dt.last)))
yLim <- range(c(0,100))
plot(0,0,xlim=xLim,ylim=yLim,type='n')

percentiles = c(0,25,50,75,95,100)
sCurve <- function(x) {
  xCoord <- c(0,
              log10(x$dt.25pct),
              log10(x$dt.50pct),
              log10(x$dt.75pct),
              log10(x$dt.95pct),
              log10(x$dt.last))
# lines(xCoord,percentiles,col=rgb(0.5,0.5,0.5,0.5))
  lines(xCoord,percentiles)
}
for (i in 1:nrow(b) ) { sCurve(b[i,]) }

xLim <- range(0,1)
yLim <- range(c(0,100))
plot(0,0,xlim=xLim,ylim=yLim,type='n')
sCurveNormal <- function(x) {
  xCoord <- c(0,
                   (x$dt.25pct/x$dt.last),
                   (x$dt.50pct/x$dt.last),
                   (x$dt.75pct/x$dt.last),
                   (x$dt.95pct/x$dt.last),
              1)
# lines(xCoord,percentiles,col=rgb(0.5,0.5,0.5,0.5))
  lines(xCoord,percentiles)
}

for (i in 1:nrow(b) ) { sCurveNormal(b[i,]) }
