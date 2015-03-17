* input used in the script: [block_latency-tagged.csv.gz](http://llr.in2p3.fr/~sartiran/data_PhEDEx_latency_v2/block_latency-tagged.csv.gz)
* documentation for fields: [PhEDEx-latency/Andrea](https://github.com/TonyWildish/PhEDEx-latency/tree/master/Andrea)


1. get data we decided to analyse
  * exclude_tag == "excluded:ok"
  * while_open_tag == "while_open:none"
  * bytes > 500GB

2. classify data into 3 groups
  * Early Stuck: first_replica_delta > 10 hours
  * Tails: last_replica - percent95_replica > 5 hours + size of last 5% / AVERAGE_TRANSFER_RATE  #AVERAGE_TRANSFER_RATE:10MB/s
  * Others

Type  |  #
----- | ---
**Early Stuck** | 18k 
**Tails** | 9k
**Others** | 9k
**Total** | 30k

3. data by data type

Type  | mcdata | realdata | otherdata
----- | ------ | -------- | ---------
**Early Stuck** | 7k | 7k | 3k
**Tails** | 4k | 4k | 1.5k
**Others** | 5k | 3k | 1.8k

4. data by transfer type
  * Almost all of transfer types are "txf_other"

5. skew variables
  * skew and skew_last variables are well-distributed
  * rskew and rskew_last variables are mainly between 0 and 4
  * Need to figure out which skew variable suits which analysis best.
