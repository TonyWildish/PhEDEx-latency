if ( !file.exists('cache/sel.lClass.slow.RData') ) {

  # create a factor variable to denote slow or stuck tails
  print("Create selectors for OK/slow/stuck/unknown latencies")
  s <- sapply(block.latency$dt.tail,function(x) {
  	if ( is.nan(x) ) { return(3) }
  	if ( x > 0.50  ) { return(2) }
  	if ( x > 0.25  ) { return(1) }
          return(0)
        } )

  block.latency$lClass <- factor(s, labels=c('OK','slow','stuck','unknown'))
  sel.lClass.OK      <- s == 0
  sel.lClass.slow    <- s == 1
  sel.lClass.stuck   <- s == 2
  sel.lClass.unknown <- s == 3
  rm(s)
  print(paste("OK:",     sum(sel.lClass.OK)))
  print(paste("slow:",   sum(sel.lClass.slow)))
  print(paste("stuck:",  sum(sel.lClass.stuck)))
  print(paste("unknown:",sum(sel.lClass.unknown)))

  print("Caching results")
  cache('sel.lClass.slow')
  cache('sel.lClass.stuck')
  cache('sel.lClass.unknown')
  cache('block.latency')
} else { print("Selection-classes: nothing to do here...") }
