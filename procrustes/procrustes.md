+++
title = "3D image registration with procrustes analysis"  

date = 2018-04-14  
draft = false  

tags = ["MATLAB", "image-analysis", "spines", "neuroscience", "image-registration"]  
summary = "Pair-wise linear transformation based on feature coordinates"  
abstract = "Pair-wise linear transformation based on feature coordinates"  

[author]
name: "Vassilis Kehayas"

[header]  
image = "procrustes/dendritic_spines_short.gif"  
caption = ""  
preview = true  
description = "An image stack acquired from a spiny dendrite inside the brain of a live mouse."  

+++


# Introduction

How can we register three-dimensional points in space 
acquired from the same structure in different time-points?
This is a problem I faced in my Ph.D. project 
where I was dealing with images of the same structure
acquired at different time-points.
For that project I was imaging dendritic spines,
microscopic protrusions emanating from neurons,
in alive mice ([Figure 1](#Fig1)).

<div id="Fig1">
  <figure>
    <img src="/img/procrustes/dendritic_spines.gif">
    <br>
    <figcaption>An image stack acquired from a spiny dendrite 
        inside the brain of a live mouse.
    </figcaption>
  </figure>
</div>

Every spine was assigned an ID and tracked over all available time-points,
and we were interested in spine positions on the dendrite.

Even though I made every effort to acquire the images under similar conditions
their alignment was never going to be perfect
from one time-point to the next.
To overcome the problems that 
such misalignments may cause 
when considering changes in distance to a fixed point over time,
say a cortical column's center or the surface of the brain,
I had to perform some sort of image registration.

Two sources of information that can be useful when registering images are 
the intensity profiles of the image and the geometry of some of the image's features.
For example, we could choose to calculate some correlation metric
based on the intensity values of the image as a whole.
Alternatively, we could take into account 
the relative positions of some structures in the image
in order to generate the geometrical transformation.
In our case, since spine morphology can change a lot from session to session,
especially since the animal received externally-generated stimulation,
I chose to focus on the second approach.

A very simple method to register images based on feature coordinates
is to apply a linear transformation,
which assumes that no warping can occur between imaging sessions,
i.e. the transformation is uniform across all structures considered.
The possible transformations under this assumption are
translation, rotation, scaling, and possibly reflection.
The solution to finding the optimal linear transformation 
based on the sum of squared errors criterion is called
[procrustes analysis](https://en.wikipedia.org/wiki/Procrustes_analysis).
Below I provide an example of procrustes analysis implemented in MATLAB
for the dendrite shown in [Figure 1](#Fig1).

<sub>
    (Please note: this post contains interactive visualizations through 
    [plot.ly](plot.ly) which are best viewed in landscape mode on mobile devices.
    Also, 3D plots are not yet supported for iPads by plotly.)
</sub>


# Implementation

First, let's have a look at the data for this example:



```matlab
data = readtable('data.csv'); % Load data
data = sortrows(data,'correlationID','ascend'); 
% Sort data based on correlation ID
disp(data(data.correlationID == 1, :))
% Select data for an example spine
```

        session    correlationID      x0        x1        y0        y1      z 
        _______    _____________    ______    ______    ______    ______    __
    
        1          1                7.1997    4.7421    33.728    33.421    13
        2          1                8.0108    5.6118    32.435     32.26    13
        3          1                8.1279    5.2061    32.497    32.387    13
        4          1                9.4179    6.6599     34.94    35.295    17
        5          1                11.554    8.9876    35.097    34.933    14
    


The above code loads the annotation data for the dendrite's spines
and displays the data for a single spine.
The variable `session` refers to the imaging day,
`correlationID` to the spine identity,
`x0` and `y0` to the coordinates of the base of the spine,
`x1` and `y1` to the coordinates of the tip of the spine,
and `z` to the slice corresponding to the plane
in which the spine had the brightest fluorescence.
All coordinates are in micrometers.

Let's then plot the annotations for all spines from the first session.
To do that I have defined a function, `selectRows`, that will simply 
return all coordinates that match a logical index,
as I will be doing that a few times.


```matlab
type('selectRows.m')
```

    
    function [X, Y, Z] = selectRows(data, ind)
      
      X = data.x0(ind);
      Y = data.y0(ind);
      Z = data.z(ind);
      
    end



```matlab
imatlab_export_fig('fig2plotly') 
% Use the plotly graphics engine 
% in a Jupyter notebook with the imatlab kernel

indSession1 = data.session == 1;
[X1, Y1, Z1] = selectRows(data, indSession1);
% Select coordinates from the first session for illustration

figure()
plot3(X1, Y1, Z1, 'ko', 'MarkerFaceColor', 'k')
```

<script type="text/javascript">window.PLOTLYENV=window.PLOTLYENV || {};window.PLOTLYENV.BASE_URL="https://plot.ly";Plotly.LINKTEXT="Export to plot.ly";</script>
<div id="cd451c02-1e5a-4c07-b590-c8a1d4c5ff93" style="height: 480px;width: 640px;" class="plotly-graph-div"></div> 
<script type="text/javascript">
 Plotly.plot("cd451c02-1e5a-4c07-b590-c8a1d4c5ff93", [{"xaxis": "x1", "yaxis": "y1", "type": "scatter3d", "visible": true, "x": [7.19973333333333, 8.80758095238095, 9.23668571428571, 9.91935238095238, 9.94411428571429, 10.0221333333333, 11.5556444444445, 11.0078857142857, 12.2561904761905, 11.8660952380952, 12.1196571428572, 12.8998476190476, 14.7685714285714, 13.3537142857143, 13.3732190476191, 15.0806476190476, 15.1444190476191, 13.9921142857143, 13.3094476190476, 9.82708571428572, 10.4654857142857, 9.35371428571429, 11.349980952381, 13.9051047619048, 15.3342095238095, 16.4122285714286, 18.7438095238095, 18.5735238095238, 18.6852952380952, 20.217180952381, 20.3289523809524, 22.6852952380952, 23.7190476190476, 24.3289523809524, 25.3484571428572, 25.6125333333333, 25.5930285714286, 27.2704380952381, 27.8660952380952, 28.9051047619048, 28.9636190476191, 29.036380952381, 29.8803428571429, 30.0611428571429, 31.9441142857143, 30.7685714285714, 31.1976761904762, 32.2366857142857, 33.1249142857143, 33.5540190476191, 34.397980952381, 33.626780952381, 34.2119238095238, 35.4512380952381, 36.1586666666667, 34.3927238095238, 35.2509333333334, 35.0116190476191, 35.7580571428572, 36.0701333333333, 37.2119238095238, 35.9531047619048, 37.3147047619048, 7.82749333333333, 8.65330666666667, 8.32562666666667, 28.3736266666667], "y": [33.7284, 31.7085142857143, 30.2794095238095, 25.2651619047619, 21.8450476190476, 21.7670285714286, 23.1481333333333, 22.4939619047619, 21.3821904761905, 17.8308, 16.8945714285714, 15.4159428571429, 15.2013904761905, 14.3716761904762, 13.571980952381, 12.2156380952381, 9.63049523809524, 8.74226666666667, 5.51346666666667, 2.66487619047619, 2.80140952380952, 0.655885714285714, 0.636380952380952, 3.40605714285714, 4.26952380952381, 5.77139047619047, 6.6296, 6.51782857142857, 8.97169523809524, 7.22525714285714, 10.1082285714286, 10.8494095238095, 13.3085333333333, 14.3475428571429, 13.0249523809524, 13.2837714285714, 15.0354666666667, 15.6791238095238, 14.3812952380952, 15.322780952381, 15.659619047619, 18.4008, 17.3812952380952, 21.8156571428571, 23.1915047619048, 24.659619047619, 24.6791238095238, 25.2890285714286, 24.172, 24.8156571428571, 25.7428952380952, 26.9574476190476, 28.0107047619048, 28.2447619047619, 29.6206095238095, 29.9521904761905, 31.9326857142857, 32.8156571428571, 32.250019047619, 33.7518857142857, 33.7961523809524, 35.1029714285714, 37.0159619047619, 28.1820533333333, 24.0389066666667, 25.1311733333333, 17.59568], "z": [13, 13, 14, 17, 18, 18, 20, 20, 21, 22, 23, 24, 26, 24, 25, 28, 28, 26, 34, 42, 38, 46, 40, 38, 33, 32, 29, 28, 28, 27, 28, 26, 23, 25, 24, 24, 25, 24, 23, 22, 21, 19, 20, 17, 15, 15, 17, 15, 16, 15, 16, 15, 15, 14, 13, 13, 12, 13, 13, 12, 11, 13, 12, 14, 16, 16, 20], "name": "", "mode": "markers", "line": {}, "marker": {"size": 6, "symbol": "circle", "line": {"width": 2, "color": "rgb(0,0,0)"}, "color": "rgb(0,0,0)"}, "showlegend": true}], {"margin": {"pad": 0, "l": 0, "r": 0, "b": 0, "t": 80}, "showlegend": false, "width": 640, "height": 480, "xaxis1": {"domain": [0.13, 0.905], "side": "bottom", "type": "linear", "anchor": "y1"}, "yaxis1": {"domain": [0.11, 0.925], "side": "left", "type": "linear", "anchor": "x1"}, "annotations": [], "title": "<b><b><\/b><\/b>"})
</script>


We want to see what kind of displacements we are facing so I am going to add spines from the second session to the previous plot:


```matlab
indSession2 = data.session == 2;
[X2, Y2, Z2] = selectRows(data, indSession2);

figure(); hold 'on';
plot3(X1, Y1, Z1, 'ko', 'MarkerFaceColor', 'k')
plot3(X2, Y2, Z2, 'ro', 'MarkerFaceColor', 'r')
legend('Session 1', 'Session 2')
```

<script type="text/javascript">window.PLOTLYENV=window.PLOTLYENV || {};window.PLOTLYENV.BASE_URL="https://plot.ly";Plotly.LINKTEXT="Export to plot.ly";</script>
<div id="471d1844-f106-488e-820c-e12b947cb421" style="height: 480px;width: 640px;" class="plotly-graph-div"></div> 
<script type="text/javascript">
 Plotly.plot("471d1844-f106-488e-820c-e12b947cb421", [{"xaxis": "x1", "yaxis": "y1", "type": "scatter3d", "visible": true, "x": [7.19973333333333, 8.80758095238095, 9.23668571428571, 9.91935238095238, 9.94411428571429, 10.0221333333333, 11.5556444444445, 11.0078857142857, 12.2561904761905, 11.8660952380952, 12.1196571428572, 12.8998476190476, 14.7685714285714, 13.3537142857143, 13.3732190476191, 15.0806476190476, 15.1444190476191, 13.9921142857143, 13.3094476190476, 9.82708571428572, 10.4654857142857, 9.35371428571429, 11.349980952381, 13.9051047619048, 15.3342095238095, 16.4122285714286, 18.7438095238095, 18.5735238095238, 18.6852952380952, 20.217180952381, 20.3289523809524, 22.6852952380952, 23.7190476190476, 24.3289523809524, 25.3484571428572, 25.6125333333333, 25.5930285714286, 27.2704380952381, 27.8660952380952, 28.9051047619048, 28.9636190476191, 29.036380952381, 29.8803428571429, 30.0611428571429, 31.9441142857143, 30.7685714285714, 31.1976761904762, 32.2366857142857, 33.1249142857143, 33.5540190476191, 34.397980952381, 33.626780952381, 34.2119238095238, 35.4512380952381, 36.1586666666667, 34.3927238095238, 35.2509333333334, 35.0116190476191, 35.7580571428572, 36.0701333333333, 37.2119238095238, 35.9531047619048, 37.3147047619048, 7.82749333333333, 8.65330666666667, 8.32562666666667, 28.3736266666667], "y": [33.7284, 31.7085142857143, 30.2794095238095, 25.2651619047619, 21.8450476190476, 21.7670285714286, 23.1481333333333, 22.4939619047619, 21.3821904761905, 17.8308, 16.8945714285714, 15.4159428571429, 15.2013904761905, 14.3716761904762, 13.571980952381, 12.2156380952381, 9.63049523809524, 8.74226666666667, 5.51346666666667, 2.66487619047619, 2.80140952380952, 0.655885714285714, 0.636380952380952, 3.40605714285714, 4.26952380952381, 5.77139047619047, 6.6296, 6.51782857142857, 8.97169523809524, 7.22525714285714, 10.1082285714286, 10.8494095238095, 13.3085333333333, 14.3475428571429, 13.0249523809524, 13.2837714285714, 15.0354666666667, 15.6791238095238, 14.3812952380952, 15.322780952381, 15.659619047619, 18.4008, 17.3812952380952, 21.8156571428571, 23.1915047619048, 24.659619047619, 24.6791238095238, 25.2890285714286, 24.172, 24.8156571428571, 25.7428952380952, 26.9574476190476, 28.0107047619048, 28.2447619047619, 29.6206095238095, 29.9521904761905, 31.9326857142857, 32.8156571428571, 32.250019047619, 33.7518857142857, 33.7961523809524, 35.1029714285714, 37.0159619047619, 28.1820533333333, 24.0389066666667, 25.1311733333333, 17.59568], "z": [13, 13, 14, 17, 18, 18, 20, 20, 21, 22, 23, 24, 26, 24, 25, 28, 28, 26, 34, 42, 38, 46, 40, 38, 33, 32, 29, 28, 28, 27, 28, 26, 23, 25, 24, 24, 25, 24, 23, 22, 21, 19, 20, 17, 15, 15, 17, 15, 16, 15, 16, 15, 15, 14, 13, 13, 12, 13, 13, 12, 11, 13, 12, 14, 16, 16, 20], "name": "Session 1", "mode": "markers", "line": {}, "marker": {"size": 6, "symbol": "circle", "line": {"width": 2, "color": "rgb(0,0,0)"}, "color": "rgb(0,0,0)"}, "showlegend": true}, {"xaxis": "x1", "yaxis": "y1", "type": "scatter3d", "visible": true, "x": [8.0108380952381, 9.99659047619048, 10.5427238095238, 10.4256952380952, 10.6402476190476, 11.9094133333333, 12.3229142857143, 11.9433333333333, 12.1031047619048, 12.7325142857143, 14.4647047619048, 13.28136, 13.3424190476191, 14.8157904761905, 14.9133142857143, 13.3281714285714, 12.8600571428571, 14.7377714285714, 15.3476761904762, 18.2058857142857, 20.3229142857143, 20.186380952381, 22.3281714285714, 24.1526285714286, 24.3866857142857, 25.4399428571429, 26.0303428571429, 26.571980952381, 27.2891619047619, 28.1721333333333, 29.4256952380952, 30.1278666666667, 30.1473714285714, 31.1083619047619, 30.367180952381, 32.7182666666667, 34.3866857142857, 33.4699619047619, 12.0888571428571, 15.8458095238095, 19.2501523809524, 31.9718285714286, 32.5622285714286, 32.5817333333333, 34.9043238095238, 34.2696571428571, 35.9965904761905, 34.9718285714286, 36.7182666666667, 37.6012380952381, 9.24489523809524, 8.72352380952381, 8.58699047619048, 8.85480000000001, 9.24489523809524, 15.2060533333333, 18.1668761904762, 22.0888571428571, 29.2253904761905, 32.2111428571429, 32.0258476190476], "y": [32.4354476190476, 29.0400952380952, 23.5524761904762, 20.4496952380952, 19.6109904761905, 21.0831733333333, 19.9673333333333, 16.5577333333333, 15.7670285714286, 14.1766285714286, 13.7422666666667, 12.9673333333333, 12.9958285714286, 10.7422666666667, 8.6252380952381, 7.39118095238095, 2.11874285714286, 3.19150476190476, 4.03546666666667, 7.85466666666666, 6.95219047619048, 8.91318095238095, 9.12773333333333, 12.2305142857143, 12.684380952381, 11.4008, 11.7181333333333, 13.6569066666667, 14.0797333333333, 12.6348571428571, 13.1915047619048, 13.9184380952381, 16.8741714285714, 15.4840761904762, 20.069219047619, 21.3475428571429, 22.9912, 22.1915047619048, 4.13299047619048, 7.03546666666666, 6.30853333333333, 23.2252571428571, 23.6506285714286, 24.9964571428571, 24.3670476190476, 26.4398095238095, 26.5373333333333, 27.4255619047619, 27.8741714285714, 32.9521904761905, 31.908819047619, 29.0596, 26.981580952381, 22.8840571428571, 23.9035619047619, 3.60890666666667, 7.77664761904762, 8.92742857142857, 15.0549714285714, 19.0302095238095, 18.6738666666667], "z": [13, 15, 20, 18, 22, 20, 23, 22, 23, 25, 25, 25, 27, 30, 29, 28, 37, 32, 32, 29, 30, 28, 27, 24, 26, 25, 24, 25, 23, 24, 23, 22, 20, 21, 19, 16, 15, 21, 39, 28, 28, 18, 16, 20, 17, 15, 15, 14, 15, 16, 12, 13, 15, 17, 17, 38, 28, 28, 21, 18, 20], "name": "Session 2", "mode": "markers", "line": {}, "marker": {"size": 6, "symbol": "circle", "line": {"width": 2, "color": "rgb(255,0,0)"}, "color": "rgb(255,0,0)"}, "showlegend": true}], {"margin": {"pad": 0, "l": 0, "r": 0, "b": 0, "t": 0}, "showlegend": true, "width": 640, "height": 480, "xaxis1": {"domain": [0.13, 0.905], "side": "bottom", "type": "linear", "anchor": "y1"}, "yaxis1": {"domain": [0.11, 0.925], "side": "left", "type": "linear", "anchor": "x1"}, "annotations": [{"showarrow": false, "xref": "paper", "yref": "paper", "xanchor": "center", "align": "center", "yanchor": "bottom", "text": "<b><b><\/b><\/b>", "x": 0.5175, "y": 0.935}], "legend": {"xanchor": "left", "yanchor": "bottom", "x": 0, "y": 0}, "title": "<b><b><\/b><\/b>", "titlefont": {"color": "rgba(0,0,0,0)"}})
</script>


We see that spines appear and disappear, and that part of the dendrite is shifted.
Next, we will select those spines that are present in both the first and second sessions:


```matlab
commonIDs = intersect(data.correlationID(indSession1), ...
                      data.correlationID(indSession2));
idInd = ismember(data.correlationID, commonIDs);

[sX1, sY1, sZ1] = selectRows(data, indSession1 & idInd);
[sX2, sY2, sZ2] = selectRows(data, indSession2 & idInd);
```

We are now ready to apply the procrustes analysis:


```matlab
[d, XYZ, C] = procrustes([sX1, sY1, sZ1], [sX2, sY2, sZ2]);
```

The sum-of-squared-errors criterion is defined as:

$$ d = \sum _ {i=1 }^{n} \sum _ {j=1}^{p} (M _ {i,j}  - N _ {i,j}) ^ 2 \enspace \text, \tag{1}
$$

where $n$ the number of spines used for the registration, 
$p$ the number of coordinates per spine $\\{ x, y, z \\}$, i.e. $p = 3$,
$M$ the coordinates of spines in the first session,
and $N$ the new set of coordinates for the second session after transformation. The function `procrustes` reports $d'$, stored in the above call in variable `d`, which is $d$ standarized by the sum of square errors of a centered version of $M$:

$$ d' = \frac {d} {\sum \sum\limits _ {i = 1}^{n} {(M _ {i}  -  \overline{M})} ^ 2} \enspace \text, \tag{2}
$$

where $\overline{M}$ the average $\\{x, y, z \\}$ coordinates across all spines of the first session.

In our example $d'$ was pretty low:


```matlab
disp(d)
```

        0.0145
    


which indicates that the registration was succesful.

The variable `XYZ` contains the transformed coordinates for the included spines of the second session.
We are not going to be using it since we are interested in applying the transformation to all spines of the second session, not just those that were also present in the first session.

The variable `C` contains the components for the tranformation:


```matlab
disp(C)
```

        T: [3×3 double]
        b: 0.9974
        c: [42×3 double]
    


`T` corresponds to the rotation and reflection component, `b` to the scale component, and `c` to the translation component. They are chosen so as to minimize $d'$ while satisfying the following equation:
$$ N = b*M'*T + c \tag{3}
$$

By simply applying this transformation to all spines of the second session we obtain the new coordinates:


```matlab
N = C.b * [X2, Y2, Z2] * C.T + C.c(1,:);
```

Let's now plot again the coordinates for spines from the first session and our new coordinates for spines from the second session, and see how we did:


```matlab
figure(); hold on;
plot3(X1, Y1, Z1, 'ko', 'MarkerFaceColor', 'k')
plot3(X2, Y2, Z2, 'ro', 'MarkerFaceColor', 'r')
plot3(N(:,1), N(:,2), N(:,3), 'bo', 'MarkerFaceColor', 'b')
legend('Original Session 1', 'Original Session 2', 'Transformed Session 2')
```

<script type="text/javascript">window.PLOTLYENV=window.PLOTLYENV || {};window.PLOTLYENV.BASE_URL="https://plot.ly";Plotly.LINKTEXT="Export to plot.ly";</script>
<div id="1635acc9-6e8c-40b7-a7b2-bfe9e164ffe8" style="height: 480px;width: 640px;" class="plotly-graph-div"></div> 
<script type="text/javascript">
 Plotly.plot("1635acc9-6e8c-40b7-a7b2-bfe9e164ffe8", [{"xaxis": "x1", "yaxis": "y1", "type": "scatter3d", "visible": true, "x": [7.19973333333333, 8.80758095238095, 9.23668571428571, 9.91935238095238, 9.94411428571429, 10.0221333333333, 11.5556444444445, 11.0078857142857, 12.2561904761905, 11.8660952380952, 12.1196571428572, 12.8998476190476, 14.7685714285714, 13.3537142857143, 13.3732190476191, 15.0806476190476, 15.1444190476191, 13.9921142857143, 13.3094476190476, 9.82708571428572, 10.4654857142857, 9.35371428571429, 11.349980952381, 13.9051047619048, 15.3342095238095, 16.4122285714286, 18.7438095238095, 18.5735238095238, 18.6852952380952, 20.217180952381, 20.3289523809524, 22.6852952380952, 23.7190476190476, 24.3289523809524, 25.3484571428572, 25.6125333333333, 25.5930285714286, 27.2704380952381, 27.8660952380952, 28.9051047619048, 28.9636190476191, 29.036380952381, 29.8803428571429, 30.0611428571429, 31.9441142857143, 30.7685714285714, 31.1976761904762, 32.2366857142857, 33.1249142857143, 33.5540190476191, 34.397980952381, 33.626780952381, 34.2119238095238, 35.4512380952381, 36.1586666666667, 34.3927238095238, 35.2509333333334, 35.0116190476191, 35.7580571428572, 36.0701333333333, 37.2119238095238, 35.9531047619048, 37.3147047619048, 7.82749333333333, 8.65330666666667, 8.32562666666667, 28.3736266666667], "y": [33.7284, 31.7085142857143, 30.2794095238095, 25.2651619047619, 21.8450476190476, 21.7670285714286, 23.1481333333333, 22.4939619047619, 21.3821904761905, 17.8308, 16.8945714285714, 15.4159428571429, 15.2013904761905, 14.3716761904762, 13.571980952381, 12.2156380952381, 9.63049523809524, 8.74226666666667, 5.51346666666667, 2.66487619047619, 2.80140952380952, 0.655885714285714, 0.636380952380952, 3.40605714285714, 4.26952380952381, 5.77139047619047, 6.6296, 6.51782857142857, 8.97169523809524, 7.22525714285714, 10.1082285714286, 10.8494095238095, 13.3085333333333, 14.3475428571429, 13.0249523809524, 13.2837714285714, 15.0354666666667, 15.6791238095238, 14.3812952380952, 15.322780952381, 15.659619047619, 18.4008, 17.3812952380952, 21.8156571428571, 23.1915047619048, 24.659619047619, 24.6791238095238, 25.2890285714286, 24.172, 24.8156571428571, 25.7428952380952, 26.9574476190476, 28.0107047619048, 28.2447619047619, 29.6206095238095, 29.9521904761905, 31.9326857142857, 32.8156571428571, 32.250019047619, 33.7518857142857, 33.7961523809524, 35.1029714285714, 37.0159619047619, 28.1820533333333, 24.0389066666667, 25.1311733333333, 17.59568], "z": [13, 13, 14, 17, 18, 18, 20, 20, 21, 22, 23, 24, 26, 24, 25, 28, 28, 26, 34, 42, 38, 46, 40, 38, 33, 32, 29, 28, 28, 27, 28, 26, 23, 25, 24, 24, 25, 24, 23, 22, 21, 19, 20, 17, 15, 15, 17, 15, 16, 15, 16, 15, 15, 14, 13, 13, 12, 13, 13, 12, 11, 13, 12, 14, 16, 16, 20], "name": "Original Session 1", "mode": "markers", "line": {}, "marker": {"size": 6, "symbol": "circle", "line": {"width": 2, "color": "rgb(0,0,0)"}, "color": "rgb(0,0,0)"}, "showlegend": true}, {"xaxis": "x1", "yaxis": "y1", "type": "scatter3d", "visible": true, "x": [8.0108380952381, 9.99659047619048, 10.5427238095238, 10.4256952380952, 10.6402476190476, 11.9094133333333, 12.3229142857143, 11.9433333333333, 12.1031047619048, 12.7325142857143, 14.4647047619048, 13.28136, 13.3424190476191, 14.8157904761905, 14.9133142857143, 13.3281714285714, 12.8600571428571, 14.7377714285714, 15.3476761904762, 18.2058857142857, 20.3229142857143, 20.186380952381, 22.3281714285714, 24.1526285714286, 24.3866857142857, 25.4399428571429, 26.0303428571429, 26.571980952381, 27.2891619047619, 28.1721333333333, 29.4256952380952, 30.1278666666667, 30.1473714285714, 31.1083619047619, 30.367180952381, 32.7182666666667, 34.3866857142857, 33.4699619047619, 12.0888571428571, 15.8458095238095, 19.2501523809524, 31.9718285714286, 32.5622285714286, 32.5817333333333, 34.9043238095238, 34.2696571428571, 35.9965904761905, 34.9718285714286, 36.7182666666667, 37.6012380952381, 9.24489523809524, 8.72352380952381, 8.58699047619048, 8.85480000000001, 9.24489523809524, 15.2060533333333, 18.1668761904762, 22.0888571428571, 29.2253904761905, 32.2111428571429, 32.0258476190476], "y": [32.4354476190476, 29.0400952380952, 23.5524761904762, 20.4496952380952, 19.6109904761905, 21.0831733333333, 19.9673333333333, 16.5577333333333, 15.7670285714286, 14.1766285714286, 13.7422666666667, 12.9673333333333, 12.9958285714286, 10.7422666666667, 8.6252380952381, 7.39118095238095, 2.11874285714286, 3.19150476190476, 4.03546666666667, 7.85466666666666, 6.95219047619048, 8.91318095238095, 9.12773333333333, 12.2305142857143, 12.684380952381, 11.4008, 11.7181333333333, 13.6569066666667, 14.0797333333333, 12.6348571428571, 13.1915047619048, 13.9184380952381, 16.8741714285714, 15.4640761904762, 20.069219047619, 21.3475428571429, 22.9912, 22.1915047619048, 4.13299047619048, 7.03546666666666, 6.30853333333333, 23.2252571428571, 23.6506285714286, 24.9964571428571, 24.3670476190476, 26.4398095238095, 26.5373333333333, 27.4255619047619, 27.8741714285714, 32.9521904761905, 31.908819047619, 29.0596, 26.981580952381, 22.8840571428571, 23.9035619047619, 3.60890666666667, 7.77664761904762, 8.92742857142857, 15.0549714285714, 19.0302095238095, 18.6738666666667], "z": [13, 15, 20, 18, 22, 20, 23, 22, 23, 25, 25, 25, 27, 30, 29, 28, 37, 32, 32, 29, 30, 28, 27, 24, 26, 25, 24, 25, 23, 24, 23, 22, 20, 21, 19, 16, 15, 21, 39, 28, 28, 18, 16, 20, 17, 15, 15, 14, 15, 16, 12, 13, 15, 17, 17, 38, 28, 28, 21, 18, 20], "name": "Original Session 2", "mode": "markers", "line": {}, "marker": {"size": 6, "symbol": "circle", "line": {"width": 2, "color": "rgb(255,0,0)"}, "color": "rgb(255,0,0)"}, "showlegend": true}, {"xaxis": "x1", "yaxis": "y1", "type": "scatter3d", "visible": true, "x": [7.01698117737414, 9.15115046437279, 9.98814682787574, 9.92236815789591, 10.2577859449592, 11.4284894868473, 11.9472168509807, 11.6532509307217, 11.861298025953, 12.5864958582666, 14.326596818863, 13.1718192602658, 13.2792708101601, 14.8903491382023, 15.0309005585022, 13.466486664047, 13.3808492325905, 15.09945111104, 15.6805399674892, 18.3367626681427, 20.4989902454373, 20.2532541118221, 22.3572483793899, 24.005925087918, 24.272305594301, 25.3389380927406, 25.8935308330015, 26.3956301609121, 27.0494798336659, 27.9990178144443, 29.2069434150897, 29.8599454686888, 29.738186902984, 30.7637435337083, 29.8322206586386, 32.0635790501567, 33.6505010988392, 32.9047345660894, 12.5959093464594, 15.9868856516157, 19.4027578585193, 31.3076453490277, 31.8350621950136, 31.9068435824148, 34.170277171213, 33.424549378904, 35.1425505029526, 34.06934701612, 35.819408864937, 36.562174782185, 8.23980722247775, 7.83426892311414, 7.81157168351942, 8.25586690056536, 8.61232505499683, 15.6954246993183, 18.2766070918498, 22.1488441872715, 28.900742987113, 31.679130856174, 31.5532604776952], "y": [33.2671213880424, 29.9883804130607, 24.6445504391921, 21.5050018683326, 20.7626062612845, 22.2260629287722, 21.1919473577747, 17.7601193687832, 16.9987301834647, 15.4766540839242, 15.0977507200098, 14.2884881257044, 14.362210154102, 12.2272002175782, 10.0985312726945, 8.79743049234318, 3.72327345462838, 4.74248604046496, 5.60266588311175, 9.43319340603342, 8.62143904843423, 10.5282454043726, 10.7871667178867, 13.8714166046079, 14.374492904251, 13.1063087602913, 13.4192911882808, 15.3902282528525, 15.7905987423366, 14.3997618532244, 14.9719442967639, 15.696652620902, 18.5997658703607, 17.265961050019, 21.7693540165942, 23.0516251368282, 24.7201459105344, 24.0247698471235, 5.75020329417532, 8.52140714770566, 7.90304801609337, 24.9432470175588, 25.3422002754827, 26.7710044632244, 26.1509860246688, 28.15365897765, 28.3047118914651, 29.1363272468786, 29.6596174006413, 34.7700241909621, 32.7590151405102, 29.9247037222284, 27.8927419186934, 23.8605877877933, 24.8888732487068, 5.30335730897403, 9.33250819991889, 10.6017726892434, 16.7795619026976, 20.7695868868042, 20.4520658894296], "z": [11.9961647839694, 14.0125651186057, 19.0986137857383, 17.1727010400296, 21.1725728478199, 19.116963248236, 22.1208961496237, 21.2047089847936, 22.214256686042, 24.2259722924459, 24.1927649541042, 24.2379008229223, 26.229583593523, 29.2314644475172, 28.2765465433374, 27.344228520424, 36.4380832316351, 31.38532146022, 31.3527451285281, 28.21227192818, 29.1763573672993, 27.1448403481842, 26.0911494265818, 22.9909326607564, 24.9694790703332, 23.9737586323904, 22.9558054872021, 23.8988468554196, 21.8787017511345, 22.884290323318, 21.845126829958, 20.8158631094276, 18.7596962286614, 19.7622316723075, 17.6905092596241, 14.6156506436094, 13.5435830418785, 19.5640387743872, 38.4084935607876, 27.2901899426471, 27.2222712669248, 16.588316420612, 14.5712144852501, 18.5300864444203, 15.4958887870979, 13.4741966087186, 13.4299752269801, 12.4395109029286, 13.3843437718482, 14.2532845889456, 10.9801711622551, 12.0494786913482, 14.0901166746077, 16.1631855369396, 16.1323003629751, 37.3464531229392, 27.2179736010985, 27.0980760820916, 19.8172103753087, 16.6703532542871, 18.6761148960656], "name": "Transformed Session 2", "mode": "markers", "line": {}, "marker": {"size": 6, "symbol": "circle", "line": {"width": 2, "color": "rgb(0,0,255)"}, "color": "rgb(0,0,255)"}, "showlegend": true}], {"margin": {"pad": 0, "l": 0, "r": 0, "b": 0, "t": 0}, "showlegend": true, "width": 640, "height": 480, "xaxis1": {"domain": [0.13, 0.905], "side": "bottom", "type": "linear", "anchor": "y1"}, "yaxis1": {"domain": [0.11, 0.925], "side": "left", "type": "linear", "anchor": "x1"}, "annotations": [{"showarrow": false, "xref": "paper", "yref": "paper", "xanchor": "center", "align": "center", "yanchor": "bottom", "text": "<b><b><\/b><\/b>", "x": 0.5175, "y": 0.935}], "legend": {"xanchor": "left", "yanchor": "bottom", "x": 0, "y": 0}, "title": "<b><b><\/b><\/b>", "titlefont": {"color": "rgba(0,0,0,0)"}})
</script>


You may want to use your mouse or finger to navigate through the image 
and click on the legend of the figure above to toggle viewing the corresponding data.
We now simply need to write a function that runs all the above for all sessions.


```matlab
type('applyProcrustes.m')
```

    
    function [N] = applyProcrustes(data)
    
    nSession = max(data.session);
    sessVector = num2cell(2:nSession);
    
    N = cellfun(@applyProcrustesSingleSession, ...
                repmat({data}, length(sessVector), 1), sessVector', ...
                'UniformOutput', 0);
    
        function [N] = applyProcrustesSingleSession(data, iS)
          
            indSession1 = data.session == 1;
            indSession2 = data.session == iS;
            [X2, Y2, Z2] = selectRows(data, indSession2);
            commonIDs = intersect(data.correlationID(indSession1), ...
                                  data.correlationID(indSession2));
            idInd = ismember(data.correlationID, commonIDs);
            
            [sX1, sY1, sZ1] = selectRows(data, indSession1 & idInd);
            [sX2, sY2, sZ2] = selectRows(data, indSession2 & idInd);
            [~, ~, C] = procrustes([sX1, sY1, sZ1], [sX2, sY2, sZ2]);
            N = C.b * [X2, Y2, Z2] * C.T + C.c(1,:);
            
        end
    
    end


All we have done is to wrap our previous commands in a sub-function
which accepts the session variable in a generalized way,
and pass that function to `cellfun` that in turn applies it to data for all sessions.
The usage of `cellfun` over a conventional for-loop is advantageous in this case,
as it provides an order of magnitude gain in speed,
something that can make a difference if the function is run over many datasets.

One thing that we could have done differently is,
instead of arbitrarily choosing one session (the first in our case) as the reference,
we could take into account information from all sessions.
For example, in generalized procrustes analysis 
the reference is chosen as an optimally determined "mean" shape.
Such functionality is already implemented in the R package [shapes](https://cran.r-project.org/web/packages/shapes/shapes.pdf).

<div align="left">
  <sub>
    The source files for this post can be found in
    <a href="https://gitlab.com/vkehayas/notebooks/tree/master/procrustes">
      https://gitlab.com/vkehayas/notebooks/tree/master/procrustes</a>.
  </sub>
</div>  

<br>
