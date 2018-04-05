% Compute all the distances between two sets of vectors
%
% Usage: [dis] = dis_L2sqr(q, v)
%
% Parameters:
%   q, v        sets of vectors (1 vector per column)
%
% Returned values
%   dis         the corresponding *square* distances
%               vectors of q corresponds to row, and columns for v
function dis = dis_L2sqr (q, v)


% vector dimension and number of vectors in the dataset
n = size (v, 2);
d = size (v, 1);
k = n;

% number of query vectors
nq = size (q, 2);

% Compute the square norm of the dataset vectors
v_nr = sum (v .* v);

% first compute the square norm the queries of the slice
d_nr = sum (q .* q)';

% the most efficient way I found to compute distances in matlab
dis = repmat (v_nr, nq, 1) + repmat (d_nr, 1, n) - 2 * q' * v;
dis = repmat (v_nr, nq, 1) + repmat (d_nr, 1, n) - 2 * q' * v;

neg = find (dis < 0) ;

dis(neg) = 0;


