This directory contains the jupyter notebook and source files for the blog post
in https://neurathsboat.blog/post/procrustes/.
To run the jupyter notebook `procrustes.ipynb` you need to have installed:   
* jupyter notebooks with the imatlab kernel and its dependencies,  
* MATLAB 2016b+ with the statistics toolbox, and  
* Plotly offline.  
For more information please see the installation instructions in 
https://github.com/imatlab/imatlab.

Alternatively, you may run the `procrustesNB.m` script in MATLAB 2014b+.
In that case you can bypass the plotly dependency 
by commenting out the following line (123):

```matlab
imatlab_export_fig('fig2plotly') 
```
