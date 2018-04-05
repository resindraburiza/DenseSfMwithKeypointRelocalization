addpath ('../../matlab')

k = 100;                   % number of cluster to create
d = 128;                   % dimensionality of the vectors
n = 10000;                 % number of vectors
v = single(rand (d, n));   % random set of vectors 
niter = 30;                % maximum number of iterations
verbose = 2;               % verbosity level
seed = 3;                  % 0: no seeding, values > 0 are used as seed
nt = 1;                    % to force multi-threading if not done by Matlab/octave
                           % check if multithreaded actived with nt=1 before 
			   % changing this variable
			   

tic
[w, mu, sigma] = yael_gmm (v, k, 'niter', niter, ...
			   'verbose', verbose, 'seed', seed);
toc

% Compute a Fisher vector
vt = single (rand(d,100));
fvt = yael_fisher (vt,w,mu,sigma);


% First compute the individual Fisher of each vector
% Check that it is the same as direct Fisher for the set
fvte = yael_fisher_elem (vt, w, mu, sigma);
fvten = sum(fvte, 2);
fvten = yael_fvecs_normalize (fvten);

[fvt fvten]