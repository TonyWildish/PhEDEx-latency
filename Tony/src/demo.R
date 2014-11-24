# Pick out the data I'm interested in...

# slow data, blocks with at least a minimum transit time
sel.slow <- block.latency$dt.last > 3600 * 4

# blocks are not too small
sel.enoughFiles <- block.latency$files > 20
sel.enoughBytes <- block.latency$bytes > 1024 * 1024 * 1024 * 20

# apply the filter
bfilt <- block.latency[sel.slow & sel.enoughFiles & sel.enoughBytes,]

# Now calculate some useful quantities
bfilt$dt.25pct = bfilt$percent25_replica - bfilt$first_replica
bfilt$dt.50pct = bfilt$percent50_replica - bfilt$first_replica
bfilt$dt.75pct = bfilt$percent75_replica - bfilt$first_replica
bfilt$dt.95pct = bfilt$percent95_replica - bfilt$first_replica
bfilt$dt.last  = bfilt$last_replica      - bfilt$first_replica

# re-filter to remove blocks with odd profiles
s1 <- bfilt$last_replica - bfilt$percent95_replica > 1
s2 <- bfilt$percent75_replica - bfilt$percent25_replica > 1
bfilt <- bfilt[ s1 & s2, ]

# Now for the variable that I hope will show interesting behaviour
bfilt$tail     = (bfilt$last_replica - bfilt$percent95_replica) * 10 /
                 (bfilt$percent75_replica - bfilt$percent25_replica)

hist( log10(bfilt$tail) )
