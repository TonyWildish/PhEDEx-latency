### Temporary repository for working on the CHEP Latency paper

This repository will eventually be absorbed into the DMWM-Analytics repository, but for now we want to be able to work on it without any interference.

There is a *bin* directory which holds a *get-log-latency.pl* script, and a *data* directory that holds CSV files of block latency data, up to a certain date (~late November 2014).

You can update the data with fresh results by running:

get-log-latency.pl --root <path to data files> --dbparam <path to your DBParam>

Your DBParam must have read access to the PhEDEx database, and you need to run this from a machine with the PhEDEx environment set up. The script will look at the files in your directory, take the latest timestamp, and get new data from that time onwards.