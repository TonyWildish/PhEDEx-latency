if ( 0 ) {
  # Create a filtered sub-sample
  # There is no (src/dst)_t(0/1/2) field!
  sel.src.T0 <- as.logical(block.latency$src_t0)
  sel.src.T1 <- as.logical(block.latency$src_t1)
  sel.src.T2 <- as.logical(block.latency$src_t2)
  cache('sel.src.T0')
  cache('sel.src.T1')
  cache('sel.src.T2')

  sel.dst.T0 <- as.logical(block.latency$dst_t0)
  sel.dst.T1 <- as.logical(block.latency$dst_t1)
  sel.dst.T2 <- as.logical(block.latency$dst_t2)
  cache('sel.dst.T0')
  cache('sel.dst.T1')
  cache('sel.dst.T2')

  # apply the filter
  bfilt <- block.latency[!sel.lClass.unknown,]

  # create a subsample for exploration
  # select blocks that take at least a respectable amount of time to transfer
  sel.long <- bfilt$dt.last > 3600 * 4

  # blocks are not too small
  sel.enoughFiles <- bfilt$files > 1
  #sel.enoughBytes <- bfilt$bytes > 1024 * 1024 * 1024 * 20

  #bsel  <- bfilt[sel.long & sel.enoughFiles & sel.enoughBytes,]
  bsel  <- bfilt[sel.long & sel.enoughFiles,]
  cache('bfilt')
  cache('bsel')
}