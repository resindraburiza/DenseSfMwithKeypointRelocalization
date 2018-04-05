% Computes a few singular values for a matrix a. The full call is 
%
% [u, s, v] = yael_svds (a, nev)
%
% if nev = min(size(a)), then a = u * diag(s) * v'. 
% 
% Reduced calls: 
%
%  s        = yael_svds (a, nev)
% [u, s]    = yael_svds (a, nev)
% [s, v]    = yael_svds (a, nev, 'v')
% 
%
%
% compared to the Matlab version, this one operates on single matrices, 
% and s is a vector (instead of a matrix).
%


