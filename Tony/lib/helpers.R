helper.function <- function() { return(1) }

savePlot <- function(filename=NULL,width=1024,height=1024) {
  cur=dev.cur()
  bmp(width=width,height=height,filename=filename)
  new=dev.cur()
  dev.set(which=cur)
  dev.copy(which=new)
  dev.off(new)
}

startDev <- function(devSize=8, width=NULL, height=NULL) {
  for (i in dev.list()) {
    dev.off()
  }
  if ( is.null(width)  ) { width = devSize }
  if ( is.null(height) ) { height = devSize }
  dev.new(width=width,height=height)
  devAskNewPage(ask=TRUE)
}
