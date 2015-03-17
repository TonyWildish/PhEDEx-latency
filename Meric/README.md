
#### Summary of the plots

* input used in the script: [block_latency-tagged.csv.gz](http://llr.in2p3.fr/~sartiran/data_PhEDEx_latency_v2/block_latency-tagged.csv.gz)
* documentation for fields: [PhEDEx-latency/Andrea](https://github.com/TonyWildish/PhEDEx-latency/tree/master/Andrea)


1. get the data we decided to analyse
  * exclude_tag == "excluded:ok"
  * while_open_tag == "while_open:none"
  * two sub-groups created:
    * large blocks (bytes > 500GB)
    * small blocks (bytes < 100GB)

2. classify data into 3 groups
  * Early Stuck: 
    * If the block transfer not started in the first 10 hours after the transfer request approval
    * (first_replica_delta > 10 hours)
    * possible reasons: Due to some missing link, privileges, or storage problems
  * Tails: 
    * If the last 5% of the block transfer not finished in the average required time + 5 hours
    * last_replica - percent95_replica > (size of last 5% / ~10MB/s) + 5 hours
    * possible reasons: missing/corrupt files in production level
  * Others
    * Block transfers without any problem in the beginning and at the end. These may or may not have a transfer latency


  Type  |  # of large blocks | # of small blocks
  ----- | ------------------ | -----------------
  **Early Stuck** | 18k | 17k
  **Tails** | 9k |  5k
  **Others** | 9k | 13k
  **Total** | 30k | 32k

3. data by data type

  Type(large blocks)  | mcdata | realdata | otherdata
  ----- | ------ | -------- | ---------
  **Early Stuck** | 7k | 7k | 3k
  **Tails** | 4k | 4k | 1.5k
  **Others** | 5k | 3k | 1.8k

  Type(small blocks)  | mcdata | realdata | otherdata
  ----- | ------ | -------- | ---------
  **Early Stuck** | 7k | 7k | 3k
  **Tails** | 2.2k | 1.5k | 1.4k
  **Others** | 7.5k | 2k | 4k

4. data by transfer type
  * Almost all of the transfer types are "txf_other"

5. skew variables
  * skew and skew_last variables are well-distributed
  * rskew and rskew_last variables are mainly between 0 and 4
  * Need to figure out which skew variable suits which analysis best.

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
