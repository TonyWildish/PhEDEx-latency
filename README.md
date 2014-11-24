### Temporary repository for working on the CHEP Latency paper

#### Overview
This repository will eventually be absorbed into the DMWM-Analytics repository, but for now we want to be able to work on it without any interference.

There is a **bin** directory which holds a **get-log-latency.pl** script, and a *data* directory that holds CSV files of block latency data, up to a certain date (~late November 2014). See the **README.md** there for more information

This file is written in Github-Flavour Markdown (https://help.github.com/articles/github-flavored-markdown/)

#### latency data
The latency information in PhEDEx is stored in a few tables, see the **Schema/OracleCoreLatency.sql** file in the PhEDEx distribution. The **t_dps_block_latency** and **t_dps_file_latency** tables hold up-to-date information on files or blocks that are currently in transfer. The **t_log_block_latency** and **t_log_file_latency** tables hold historical data for completed files or blocks.

The **t_log_file_latency** table is cleaned after three months (I think) to prevent it from growing too large. If we want to analyse file-latency from historical data (at some point in the future) then we need to plan to keep that data from now. The **get-log-latency.pl** script can take care of that.

For this paper, we are only interested in the block-level latency, so we only need the **t_log_block_latency** table.