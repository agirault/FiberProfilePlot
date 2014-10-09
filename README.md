#FiberProfilePlot

*Date : 06/30/2014*
*Author : Alexis Girault*

##Introduction
This script was built to plot the DTI Metrics (FA, MD, RD, AD) along Arclength, for each fiber track of a dataset.The values displayed are stored in a CSV file computed by DTIFiberAnalyzer, part of the DTI pipeline at NIRAL.
The reason this tool was created was to overcome a bug with OpenOffice that would not allow to have more than 200 columns (then cases).
The script computes a .m file and runs it with Matlab to print the plots in a PDF file. You can then run the .m file again and it will display a figure in matlab with interative plots to select and analyze each of them.

##Requirements
- Matlab

##Usage of the scripts

- FiberProfilePlot needs to be run in a terminal.
- To process a CSV file, you can put his filepath as a parameter
```
eg : FiberProfilePlot ad_UNC_Right.csv
```
- You can give a directory path as a parameter, and FiberProfilePlot will process all the CSV files in it and in the sub-directories
```
eg : FiberProfilePlot directory/
```
- You can also put multiple parameters
```
eg : FiberProfilePlot ad_UNC_Right.csv fa_UNC_Right.csv directory/
```

