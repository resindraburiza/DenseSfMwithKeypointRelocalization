% This function learn a diagonal form Gaussian mixture
% 
% Usage:
%  [w, mu, sigma] = yael_gmm (v, k)
%  [w, mu, sigma] = yael_gmm (v, k, opts)
%
% where w, mu and sigma are the parameters of the mixture:
%    w is the weights of the different Gaussian
%    mu contains the mean of all Gaussians (one Gaussian per column)
%    sigma contains the diagonal variance of all Gaussian (one Gaussian per column)
% 
% Available options are:
%    redo       number of times the initializing k-means is run (best clustering returned)
%    niter      number of iteration in the k-means
%    verbose    the verbosity level. 0: no output, 1 (default), 2: detailled
%    nt         number of threads. For octave users. 
%               Warning: nt=1 (default) should provide 
%               multi-threading depending on matlab version or architecture. 
%               Warning: do not use nt>1 in that case, at it will cause 
%               memory leaks
%    seed       0 by default. Specify a value !=0 to randomize initalization

