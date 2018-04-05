% This function performs the clustering of a set of vector v in k clusters
% 
% C = yael_kmeans (v, k)
% [C, I] = yael_kmeans (v, k)
% [C, D, I] = yael_kmeans (v, k)
% [C, D, I, Nassign] = yael_kmeans (v, k)
% returns a set of k centroids, stored column-wise in C
% The input vectors are given in the matrix V (one vector per column)
% 
% Optionally the function can returns
%   I: the cluster index associated with each input vector, 
%   D: the square distance D between each vector and its centroid,
%   Nassign: the total number of centroids assigned to each cluster
% 
% Options: typical usage:
% C = yael_kmeans (v, k, 'redo', redo, 'verbose', verbose, 'seed', seed, 'niter', niter)
%
% Available options are:
%    redo       number of times the k-means is run (best clustering returned)
%    verbose    the verbosity level. 0: no output, 1 (default), 2: detailled
%    seed       0 by default. Specify a value !=0 to set a specific seed
%    init       1 by default. 0=kmeans++ initialization, 1=random centers
%    niter      number of iterations (default: 50)
