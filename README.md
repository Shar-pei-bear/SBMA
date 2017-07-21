Project name: SBMA

Description: an attempt to combine mean_shift_algorithm with diamond search algorithm to perform motion estimation. The algorithm is based on two papers: http://coewww.rutgers.edu/riul/research/papers/pdf/feature.pdf and http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.330.3947&rep=rep1&type=pdf.

Table of Contents:

    Mean_shift_Algorithm2.m：implementation of mean shift algorithm

    Diamond_Search_Algorithm5.m：implementation of damond search algorithm, the block shape is square.

    Diamond_Search_Algorithm4.m：implementation of damond search algorithm, the block shape is arbitrary.

    flowToColor.m, computeColor.m：transform flow filed to color image.

    demoflowToColor.m: an example of how to transform flow filed to color image.

    BMA.m: calculate the flow field using diamond searh algorithm.

    SBMA.m: calculate the flow field combing diamond search algorithm and mean shift algorithm.

    ErrorPlot.m：plot the error between the calculated flow filed and the ground truth.

Installation: matlab and a c compiler are needed.

Usage: see an example of usage in BMA.m and SBMA.m

License: MIT license
