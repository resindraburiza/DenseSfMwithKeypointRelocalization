addpath ('../../matlab')

k = 1000;                   % number of cluster to create
d = 128;                   % dimensionality of the vectors
n = 10000;                 % number of vectors
v = single(rand (d, n));   % random set of vectors 
niter = 30;                % maximum number of iterations
verbose = 1;               % verbosity level
seed = 3;                  % 0: no seeding, values > 0 are used as seed
			   

tic
centroids = yael_kmeans (v, k, 'niter', niter, ...
			 'verbose', verbose, 'seed', seed);
toc
