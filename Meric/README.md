
### Cleaning the data

1- get non-growing samples during the transfer
'while_open_tag'='while_open:none'
- none: block closed before subscription

2- cut-offs
'exclude_tag':'excluded:ok'
- infskewX: the skew_Y with Y<=X has "infinite" value
- infrskewX: the rskew_Y with Y<=X has "infinite" value
- infskew_lastX: the skew_last_Y with Y<=X has "infinite" value
- infrskew_lastX: the rskew_last_Y with Y<=X has "infinite" value
- short: transfer took less than 3 hours
- susp: the transfer was suspended for some time
- small: transfers with less than 5 files
- bunny: BUNNIES blocks

### Latency
#### Latency of big blocks with long tails
__Cause__
* Missing/Corrupt files in production level

__Detect__
* last_replica_delta - percent95_replica_delta > 10 hours + offset[size of last 5% / 5 MB/s]
* skew_95: X:Y higher than N(5)
* rskew_last_5: X:Y close to 0

__Filter Data__
* size > 300GB
* remove early stucks
* remove if last_replica_delta - percent95_replica_delta < ..
* remove if skew_95<N or rskew_last_5>M (the ones with no or smaller latency), but in theory there should not be any remaining sample like this.

__Plot__
* # of blocks vs Data Type, Transfer Type, Tier Type
* Transfer vs (total_xfer_attempts/files)
* skew_95 vs rskew_last_5
* skew_95 vs rskew_95

#### Latency of blocks that get stuck early
__Cause__
* Missing link
* No replica for the file
* full destination queue due to other transfers
* other src/dst site errors

__Detect__
* first_replica_delta > 10 hours + offset[avg_file_size / 5 MB/s]
* skew_25: X:Y close to 0                     
* rskew_last_75: X:Y higher than N(5)   

__Filter Data__
* remove if first_replica_delta < ..
* remove if skew_25>M or rskew_last_75<N

__Plot__
* same

#### Latency of datasets with many small blocks
__Cause__
* As each block might be produced at a different site, some of the blocks located at problematic sites can cause latency in dataset level transfers

__Detect__
* these should be mainly custodial subscriptions from T2s and T1_Disks to tape endpoints since those are the transfers collecting partial blocks into one location with a dataset level subscription  (‘transfer_type_tag’:txf_mcupload or ‘is_custodial’:y&src_tier=2)

__Filter Data__
* Aggregate block level info to get dataset level info
* Get number of blocks which have low/high latency values

__Plot__
* same

#### Idea of new skew variables
- **skew:** If transfers happen at a constant rate, the skew should be one for all values of X
```
(time spent transferring the LAST 5 percent of the files) / (time spent transferring the FIRST X percent of the files) times X/5
```
- **rskew, rslew_last variables:**
skew variables won't work for the transfers stuck after 95% as it uses transfer time of the last 5% as basis. Therefore, using the first 25% as basis can help here
```
(time spent transferring the FIRST 25 percent of the files) / (time spent transferring the FIRST|LAST X percent of the files) times X/25
```

- **skew_last, rskew_last variables:**
if the transfer got stuck in the first %25 part only, all the skew variables will be higher than 1 although it has a constant rate after 25%. So if we have skew_last values, we can use it for these cases to check whether the rate was constant in the last X%.
```
(time spent transferring the FIRST|LAST [25|5] percent of the files) / (time spent transferring the LAST X percent of the files) times X/[25|5]
```

#### Notes
* Twiki: https://twiki.cern.ch/twiki/bin/view/Main/DMWMAnalyticsBlockLatency
* If we had one dataset/block per day suffering from a latency problem we would have only 1000 or so datasets/blocks to discover of interest to us. We should not be afraid to cut hard into the dataset if it cleans things up!
* For each latency type, look correlation with tiers(sources and destinations), data type(data, mc), transfer type
