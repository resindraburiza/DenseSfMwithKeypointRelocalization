% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software. 
% See http://www.cecill.info/licences.en.html
%
% This package was written by Herve Jegou
% Copyright (C) INRIA 2013-2014


% load the vectors from test/training/query sets, and the groundtruth
% if dataset='random', a random dataset is generated on the fly
%           ='siftsmall', the siftsmall is used (from basedir directory)
%           ='sift', the sift dataset is used (frome basedir directory)
%           ='gist', the sift dataset is used (frome basedir directory)
dataset = 'sift';

% Load the vectors contained in a basedir
% Best is to define the variable datadir before executing this script
datadir = '/nfs/pyrex/raid6/vectors/annfvecs/';
anndata_load_vectors;


%---[ Search parameters ]---

nbits = 128;          % number of projection bits
coarsek = 2048;       % number of centroids for the coarse quantizer
w = 1;                % number of cell visited per query
htlist = [18 24];     % list of test hamming thresholds (assuming nbits=64)

tic;

% Provide the quantizer
quantizer = @yael_nn;
qparams = yael_kmeans (vtrain, coarsek, 'niter', 20, 'verbose', 0);

ivfhe = yael_ivf_he (coarsek, nbits, vtrain, quantizer, qparams);
fprintf ('* Learned the IVF structure in %.3f seconds\n', toc); 

% encode the database vectors: ivf is a structure containing two sets of k cells
% Each cell contains a set of idx/codes associated with a given coarse centroid

tic
ivfhe.add (ivfhe, int32(1:nbase), vbase);
fprintf ('* Add vectors to the structure in %.3f seconds\n', toc); 


fivf_name = 'test.ivf';
fprintf ('* Save the inverted file to %s\n', fivf_name);
ivfhe.save (ivfhe, fivf_name);

fprintf ('* Free the inverted file\n');

% Free the variables associated with the inverted file
yael_ivf ('free');
clear ivfhe;

fprintf ('* Load the inverted file from %s\n', fivf_name);
ivfhe = yael_ivf_he (fivf_name);

%---[ perform the search and compare with the ground-truth ]---

if 0
% Perform the queries
nquery = nbase;
vquery = vbase (:, 1:nquery);

for hti = htlist
  ht = floor (hti * nbits / 64);
  tic
  matches = ivfhe.query (ivfhe, int32(1:nquery), vquery, ht);

  % Remove duplicate matches due to symmetry and self-matches
  idx = find (matches(1,:) < matches(2,:));
  matches = matches (:, idx);

  fprintf ('* %d Queries performed in %.3f seconds - ht=%d\n', nquery, toc, ht);
  fprintf ('-> found %d matches\n', size (matches, 2));
end
matches = double(matches);
smatches = sparse(matches(1,:), matches(2,:), matches(3,:));
end

if 1
for hti = htlist
  ht = floor (hti * nbits / 64);

  tic
  nm0 = yael_ivf ('crossmatchcount', ht);
  fprintf ('* Cross-matching count in %.3f seconds - ht=%d -> %ld matches\n', ...
           toc, ht, sum(nm0));
  
  tic
  [m, nm] = yael_ivf ('crossmatch', ht);
  fprintf ('* Cross-matching performed in %.3f seconds - ht=%d -> %ld matches\n', ...
         toc, ht, sum(nm));

  tic
  [idx3, sc, nm3, keys] = yael_ivf ('crossmatchalt', ht);
  fprintf ('* Cross-matching/alt performed in %.3f seconds - ht=%d -> %ld matches\n', ...
    toc, ht, sum(nm3));
end
end


yael_ivf ('free');
