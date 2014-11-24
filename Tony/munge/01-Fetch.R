read_raw_csv <- function() {
  data_file <- 'cache/block.latency.RData'
  if ( file.exists(data_file) ) {
    print(paste0("Loading saved data from ",data_file))
    load(data_file)
  }

  path_to_data <- '../data/Version-01'
  csv_files <- list.files(path=path_to_data, full.names=TRUE, pattern='block_latency-[0-9]*.csv.gz')

  print(paste0("Reading ",csv_files[1],", (1 of ",length(csv_files),")"))
  df <- read.csv(file=csv_files[1])
  for ( i in 2:length(csv_files) ) {
    print(paste0("Reading ",csv_files[i],", (",i," of ",length(csv_files),")"))
    df <- rbind(df,read.csv(file=csv_files[1]))
  }

  # Derived values: the interval between percentiles, instead of absolute epoch times
  print("Calculating intervals from beginning of replication")
  df$dt.last  <- (df$last_replica      - df$first_replica)
  df$dt.25pct <- (df$percent25_replica - df$first_replica) / df$dt.last
  df$dt.50pct <- (df$percent50_replica - df$first_replica) / df$dt.last
  df$dt.75pct <- (df$percent75_replica - df$first_replica) / df$dt.last
  df$dt.95pct <- (df$percent95_replica - df$first_replica) / df$dt.last
  df$dt.tail  <- 1 - df$dt.95pct

  # Now for the variables that I hope will show interesting behaviour, the skew values.
  # These are the fraction of the time in the tail as a fraction of the time elsewhere, normalised.
  # if there is nothing causing latency, this should be exactly 1
  print("Calculating skew variables...")
  cat("skew5_100 ")
  df$skew5_100 <- df$dt.tail * 20
  cat("skew5_195 ")
  df$skew5_95  <- df$dt.tail * 19 / df$dt.95pct
  cat("skew5_75 ")
  df$skew5_75  <- df$dt.tail * 15 / df$dt.75pct
  cat("skew5_50 ")
  df$skew5_50  <- df$dt.tail * 10 / df$dt.50pct
  cat("skew5_25")
  df$skew5_25  <- df$dt.tail *  5 / df$dt.25pct
  print(" ")

  print(paste0("Saving data to ",data_file))
  return(df)
}

if ( length(ls(pattern="block.latency")) ) {
  print("block.latency frame already exists, nothing to do...")
} else {
  block.latency <- read_raw_csv()
  cache('block.latency')
}