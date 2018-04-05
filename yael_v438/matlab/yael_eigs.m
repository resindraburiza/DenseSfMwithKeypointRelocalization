% Computes a few eigenvalues/vectors for a symmetric matrix a.
% 
% [eigenvecs, eigenvals] = yael_eigs (a, nev)
%
% compared to the Matlab version, this one operates on single matrices, 
% and eigenvals is a vector (instead of a matrix).
%
% requires nev <= size(v, 1) / 2  (otherwise it's better to compute all eigenvectors anyway).
% 

