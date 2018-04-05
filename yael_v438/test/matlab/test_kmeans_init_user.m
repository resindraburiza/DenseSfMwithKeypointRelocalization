addpath ('../../matlab')

k = 100;                   % number of cluster to create
d = 128;                   % dimensionality of the vectors
n = 10000;                 % number of vectors
v = single(rand (d, n));   % random set of vectors 
niter = 30;                % maximum number of iterations
verbose = 1;               % verbosity level
seed = 3;                  % 0: no seeding, values > 0 are used as seed
nt = 2;                    % to force multi-threading if not done by Matlab/octave
                           % check if multithreaded actived with nt=1 before 
			   % changing this variable
			   
% provides initialization
cinit = randperm (n);
cinit = cinit (1:k);

tic
centroids = v(:, cinit);
for i = 1:3

centroids = yael_kmeans_init_user (v, k, centroids, 'niter', niter, 'nt', nt, ...
				   'verbose', verbose, 'seed', seed);
end

toc
