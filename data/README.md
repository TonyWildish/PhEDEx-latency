#### Data for the latency analysis
I have an initial version of the data produced by the **bin/get-log-latency.pl** script in the **Version-01** directory here. I named it with a version to allow for the possibility that we might change the fields etc, in which case we'll need to update the data, but may still want access to the original version for some reason.

 See the **README.md** in the **bin** directory for details of how to reproduce this data or how to extend the dataset with new data.

 **N.B.** Github has a limit of 100 MB for files, so plain CSV files are soon going to fill this up. Better gzip or bzip2 the files before committing them to the repository. If your analysis can read the gzipped/bzipped form directly, so much the better, there will be no need to confuse git with files bouncing between zipped an unzipped forms.