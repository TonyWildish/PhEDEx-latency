if ( !file.exists('cache/bfilt.RData') ) {
  # Create a filtered sub-sample
  print("Creating filters for sub-samples")
  print("src")
  sel.src.T0 <- as.logical(block.latency$src_tier == 0)
  sel.src.T1 <- as.logical(block.latency$src_tier == 1)
  sel.src.T2 <- as.logical(block.latency$src_tier == 2)
  cache('sel.src.T0')
  cache('sel.src.T1')
  cache('sel.src.T2')

  print("dst")
  sel.dst.T0 <- as.logical(block.latency$dst_tier == 0)
  sel.dst.T1 <- as.logical(block.latency$dst_tier == 1)
  sel.dst.T2 <- as.logical(block.latency$dst_tier == 2)
  cache('sel.dst.T0')
  cache('sel.dst.T1')
  cache('sel.dst.T2')

  # apply the filter
  print("bfilt")
  bfilt <- block.latency[!sel.lClass.unknown,]

  # create a subsample for exploration
  # select blocks that take at least a respectable amount of time to transfer
  sel.long <- bfilt$dt.last > 3600 * 4

  # blocks are not too small
  sel.enoughFiles <- bfilt$files > 1
  #sel.enoughBytes <- bfilt$bytes > 1024 * 1024 * 1024 * 20

  #bsel  <- bfilt[sel.long & sel.enoughFiles & sel.enoughBytes,]
  print("bsel")
  bsel  <- bfilt[sel.long & sel.enoughFiles,]
  cache('bfilt')
  cache('bsel')
} else { print("Filter: nothing to do here...") }