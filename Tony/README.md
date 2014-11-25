This project was created by ProjectTemplate, see http://projecttemplate.net

This project contains files to fetch and analyse PhEDEx block-latency data in R

To load the data, start R, install the project template package if you haven't done so yet (see URL above), and then **load.project()**. The first time you run this it will fetch the data from the ../data directory (see **munge/01-Fetch.R** for the exact path). It then post-processes it and produces a bunch of **RData** files in the **cache** directory. Next time you load the project, these cached files are read, which speeds things up quite a bit.

Please don't check the contents of the cache directory into github. This will bloat the repository considerably, which is not good.

To see some sample analyses, take a look in the **src** directory. Simply executing **source('src/filename.R')** should produce something. These scripts are very preliminary, so don't expect much from them yet.
