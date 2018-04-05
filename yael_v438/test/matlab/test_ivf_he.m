% This sample program shows how to use the Hamming embedding technique
% described in "Improving bag-of-features for large scale image search"
%
% Thisimplementation is not as efficient as the C/python one used in our paper.
% However it provides same accuracy and same memory usage for this parameter. 
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software. 
% See http://www.cecill.info/licences.en.html
%
% This package was written by Herve Jegou
% Copyright (C) INRIA 2008-2013

setenv ('YAELCFLAGS', '-msse4 -I/usr/include -I/Users/hjegou/src/yael -DFINTEGER=long -DHAVE_ARPACK');


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

ht = 64;              % Hamming threshold
nbits = 128;          % number of subquantizers to be used (m in the paper)
coarsek = 256;        % number of centroids for the coarse quantizer
w = 4;                % number of cell visited per query

tic;

% Provide the quantizer: yael exact assignment
quantizer = @yael_nn;
qparams = yael_kmeans (vtrain, coarsek, 'niter', 20, 'verbose', 0);

ivfhe = yael_ivf_he (coarsek, nbits, vtrain, quantizer, qparams);
fprintf ('* Learned the IVF structure in %.3f seconds\n', toc); 

% encode the database vectors: ivf is a structure containing two sets of k cells
% Each cell contains a set of idx/codes associated with a given coarse centroid

ivfhe.add (ivfhe, int32(1:nbase), vbase);


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

% Perform the queries
nquery = size (vquery, 2);
nquery = 10000;
vquery = vquery (:, 1:nquery);

for hti = [12:2:24]
  ht = floor (hti * nbits / 64);
  tic
  matches = ivfhe.query (ivfhe, int32(1:nquery), vquery, ht);
  fprintf ('* %d Queries performed in %.3f seconds - ht=%d\n', nquery, toc, ht);
  fprintf ('-> found %d matches\n', size (matches, 2));
end

ivfhe.scoremap = single (exp(- ((0:nbits)/16).^2));
ivfhe.scoremap = single (1:-2/nbits:-1).^2;
ivfhe.scoremap(floor(nbits/2):nbits+1)=0;

ivfhe.listw = single(ones(1, coarsek));

for hti = [12:2:24]
ht = floor (hti * nbits / 64);
tic
[mids, msc] = ivfhe.queryw (ivfhe, int32(1:nquery), vquery, ht);
fprintf ('* %d Queries performed in %.3f seconds - ht=%d\n', nquery, toc, ht);
fprintf ('-> found %d matches\n', size (mids, 2));
end


%yael_ivf ('free');
