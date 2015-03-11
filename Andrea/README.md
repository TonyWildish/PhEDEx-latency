Here e have just few scripts that get the block latency data, parse corresponding csv files, aggregates other info, add derived fields and tags. 
[Here you can find data up to 09/02/2015](http://llr.in2p3.fr/~sartiran/data_PhEDEx_latency/). If you want to create the data by yourself see below.

### Quick how-to

#### Getting Data

put yourself in the `PhEDEx-latency/Andrea` directory. Then run

```
src/get-log-latency.pl --dbparam=<DBPARAMS>
```

iterate until you have recovered all the data. Then recover nodes and blocks info.

```
src/get-nodes.pl --dbparam=<DBPARAMS>
src/get-blocks.pl --dbparam=<DBPARAMS>
```

#### Processing Data

and run the following processing steps:
```
src/aggregate-data.pl
```
will create `data/block_latency-aggregated.csv` file with all the entries completed by the names of blocks and of source/destination nodes.

```
src/process-data.pl
```

will create `data/block_latency-rejected.csv` with the ill defined entries. The well defined entries are listed in `data/block_latency-processed.csv` with some derived fields added.

```
'time_subscription_hr' --> human readable version of the subscription time
'block_create_delta' --> time difference between the subscription and the block creation time in seconds
'block_close_delta'  --> time difference between the subscription and the block closing time in seconds
'first_request_delta  --> time difference between the subscription and the first request time in seconds
'first_replica_delta'  --> time difference between the subscription and the first replica time in seconds
'percent25_replica_delta' --> ....idem
'percent50_replica_delta' --> ...idem
'percent75_replica_delta' --> ...idem
'percent95_replica_delta' --> ...idem
'last_replica_delta'  --> idem
'primary_from_fraction' --> fraction of files that were copied from the primary source node
'avg_file_size' --> average size of the file
'eff_avg_rate' --> average effective rate (i.e. from subscription)
'trans_avg_rate' --> average transfer rate (i.e. from first request)
'skew_25' --> the skew variable defiened by Tony. If infinite (i.e. if 25 replica time and the first replica time coincide) the value is skew_25_infinite
'skew_50' --> ..idem
'skew_75' --> ..idem
'skew_95' --> ..idem 
```

Then we can run 

```
src/tag-data.pl
```

which will create `data/block_latency-tagged.csv` adding some tags to each entry

```
'data_type_tag': type of data. values are
                            'realdata' if the name match /^\/\S+\/Run20\S+\/\S+$/
                            'mcdata' if the name match /^\/\S+\/(Spring|Summer|Fall|Winter)\S+\/\S+$/
                            'otherdata' otherwise

                            Some other data can be identified - e.g. StoreResults - if needed

'transfer_type_tag': type od transfer. values are
                                 'txf_t0t1dist' if it is a custodial transfer from T0 (exclusively) to a T1
                                 'txf_mcupload' if it is a custodial transfer from T2 to T1 of mcdata
                                 'txf_migr' if it is a pure migration from a node Buffe/Disk to the same node MSS


 'files_number_tag': a tag characterizing the blocks by the number of files they have in.
                               value is Nfiles for a block with <= N files. With N=1000,500,100,50,20,10,5,4,3,2,1
                               block with mode the 1000 files have value extrafile.


'files_size_tag' : a tag characterizing the blocks by the average size of the files they have in.
                          value is Xfiles for an average size <= X with X=10G,5G,2G,1G,500M,100M
                          blocks with an average size of more than 10GB are tagged 'bigfiles'

'while_open_tag' : which has values while_open:X with X:
        none: block closed before subscription
        sub: block opened while subscription
        1st_req: block opened while 1st request
        1st_rep: block opened while 1st replica
        25perc: block opened while 25%  transferred
        50perc: block opened while 50%  transferred
        75perc: block opened while 75%  transferred
        95perc: block opened while 95%  transferred
        last: last opened while last replica done


'exclude_tag' : this just tags some entries which we may want o exclude for one reason or another. The value is excluded:<reason>
                        values for <reasons> are (we keep the last that matches):
                              - infskewX: the skew_Y with Y<=X has "infinite" value
                              - short: transfer took less than 3 hours
                              - susp: the transfer was suspended for some time
                              - small: transfers with less than 5 files
                              - bunny: BUNNIES blocks
                        all the others are marked excluded:ok

```

Then we can run 

```
src/count.pl
src/mkhysto.pl
```

and we get a file `data/block_latency-hysto.csv` with 1 line for each tag combination and, for each line, the total number of entries/files/bytes matching that tag combination.

