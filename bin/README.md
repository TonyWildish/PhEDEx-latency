The **get-log-latency.pl** script fetches data from the PhEDEx data-service. Run it with **--help** for details. Although it can fetch either block-latency or file-latency information, we can ignore the file-latency information for this analysis.

The data this script fetches is stored in the **data** directory. You can update the data with fresh results by running:

```
get-log-latency.pl --root path_to_data_files --dbparam path_to_your_DBParam
```

Your DBParam must have read access to the PhEDEx database, and you need to run this from a machine with the PhEDEx environment set up, so SLC5 or SLC6. Take a look at https://twiki.cern.ch/twiki/bin/view/CMSPublic/PhedexAdminDocsInstallation#Software_Install for instructions. It doesn't take much CPU/RAM to run, and the data is small, so it can easily fit on your PhEDEx vobox, if you have one.

The script will look at the files in your data directory, take the latest timestamp, and get new data from that time onwards. You don't need to run it more than once per month, unless you want last-minute information. If you want a clean start you can simply **rm** the data files and start again.

For details of the fields recorded by the script, look at the SQL it executes. This doesn't record text fields (site name etc), instead it records their ID in the PhEDEx tables. Also, it has no knowledge of the data-tiers etc. Some of that may be needed, in which case it will be necessary to extend the script. For simple clustering of the data, to see what sort of latency profiles we hace, the initial version is probably enough.