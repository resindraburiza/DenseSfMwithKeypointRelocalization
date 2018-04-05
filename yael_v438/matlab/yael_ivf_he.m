% Construct Hamming Embedding structure from a learning set
% WARNING: this is a very slow implementation of HE, for exposition purpose only
% 
% Usage: ivf = ivfhe_new (k, nbits, v, quantizer, C, idx)
%        ivf = vifhe_new (k, nbits, v, C)
% where
%   k          number of centroids (=visual words) for the inverted file
%   nbits      number of bits for the signature
%   v          the set of vectors using for learning the structure
%   C          use a pre-learned set of centroids instead of learning it with v
%   quantizer  is a user-defined function for quantization 
%              If defined, C is its first parameter (of any desired type)
%		idx 			 precomputed quantization cells for learning vectors v
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software. 
% See http://www.cecill.info/licences.en.html
%
% This package was written by Herve Jegou
% Copyright (C) INRIA 2011-2013
% Last change: May 2013. 

function ivfhe = yael_ivf_he (k, nbits, v, quantizer, quantizer_params, idx)

% If a filename is provided as sole argument, then load from disk
if nargin == 1
   ivfhe = ivfhe_load (k); 
   return;
end

ivfhe.verbose = false;
n = size (v, 2);     % number of vectors in the training set
d = size (v, 1);     % vector dimension
niter = 50;

ivfhe.k = k;
ivfhe.d = size (v, 1);
ivfhe.nbits = nbits;
ivfhe.elemsize = nbits / 8;
assert (mod(nbits, 8) == 0);

%--- first draw a random rotation matrix ---
[ivfhe.Q, ~] = qr (randn(d));
ivfhe.Q = ivfhe.Q (1:ivfhe.nbits, :);

%--- first learn the coarse quantizer and a random rotation matrix ---
if ~exist('quantizer')
  ivfhe.quantizer = @yael_nn;   % NN rule by default
else
  ivfhe.quantizer = quantizer;
end

if ~exist('quantizer_params')
  ivfhe.quantizer_params = yael_kmeans (v, k, 'niter', niter, 'verbose', 0);
else
  ivfhe.quantizer_params = quantizer_params; 
end

%--- compute the median values ---

% Assign and re-organize the vector per cell using the given quantization method
if ~exist('idx')
	[idx, ~] = ivfhe.quantizer (ivfhe.quantizer_params, v);
end

% Learn the median values
ivfhe.medians = ivfhe_learn_medians (ivfhe, v, idx);

% Construct a matrix to help the binarization
m = 2.^(0:7);
M = m;
for i = 2:ivfhe.elemsize
  M = blkdiag (M, m);
end
ivfhe.bin2compactbin = M;

yael_ivf ('free');
yael_ivf ('new', ivfhe.k, ivfhe.elemsize);


% The methods associated with the ivfhe structure
ivfhe.binsign = @ivfhe_binsign;
ivfhe.add = @ivfhe_add;
ivfhe.query = @ivfhe_query;
ivfhe.queryw = @ivfhe_queryw;
ivfhe.getids = @ivfhe_getids;
ivfhe.save = @ivfhe_save;
ivfhe.load = @ivfhe_load;
ivfhe.imbfactor = @ivfhe_imbfactor;
ivfhe.findbs = @ivfhe_findbs;

%------------------------------------------------------------
function medians = ivfhe_learn_medians (ivfhe, v, idx)

n = size (v, 2);     % number of vectors in the training set
d = size (v, 1);     % vector dimension
assert (ivfhe.d == d);


%--- compute the median values ---

% Assign and re-organize the vector per cell
[~, ids] = sort (idx);
v = v (:, ids);
h = hist (double(idx), 1:ivfhe.k);

% check if there is at least one value per cell
novalcell = find (h == 0);
lnovalcell = length (novalcell);
if lnovalcell > 0
  fprintf ('# Error: found %d cell with no vector to learn the median values\n', lnovalcell);
end

cumh = [0 cumsum(h)];

% Fixed random projection
v = ivfhe.Q * v;

% By default, if no descriptor in the cell, use as median the projected centroid itself
for i = 1:ivfhe.k
  hstart = cumh (i) + 1;
  hend = cumh (i+1);
  
  % no descriptor in cell
  if hstart > hend,  continue; end
  
  vsub = v (:, hstart:hend);
  medians (:, i) = median (vsub, 2);
end


%------------------------------------------------------------
% ivfhe_binsign: Compute the binary signature associated with a set of vectors
% Usage: bs = ivfhe_binsign (v);
% Usage: bs = ivfhe_binsign (v, idx, w);
%
% Parameters:
%  ivfhe   The inverted file parameter structure
%  v       The input vector 
%  idx     (optional, computed if not given) the set of quantized indexes associated with
%  w       (optional, default=1) multiple assignment
function bs = ivfhe_binsign (ivfhe, v, idx, w)

% w not used at this stage
assert (nargin < 4);

% find the indexes for the coarse quantizer
if nargin < 3
  [idx,~] = ivfhe.quantizer (ivfhe.quantizer_params, v);
end

% project the vectors using the rotation matrix and compute the binary signature
bs = (ivfhe.medians(:, idx) < (ivfhe.Q * v));

% Convert this binary matrix into a compact format
bs = uint8 (ivfhe.bin2compactbin*bs);


%------------------------------------------------------------
% ivfhe_add: Add some vector to the index
%   ivfhe 
%   ids     vectors identifiers
%   idx     quantization cell
%   codes:  binary code (int uint8 format)
function [vidx, codes] = ivfhe_add (ivfhe, ids, v, vidx, codes)

if ~exist ('vidx')
  tic
  [vidx, dis] = ivfhe.quantizer (ivfhe.quantizer_params, v);
  if ivfhe.verbose, fprintf ('* Quantization done in %.3f seconds\n', toc); end
end

if ~exist ('codes')
  tic
  codes = ivfhe.binsign (ivfhe, v, vidx);
  if ivfhe.verbose, fprintf ('* Binary signatures computed in %.3f seconds\n', toc); end
end

yael_ivf ('add', int32(ids), int32(vidx), codes);


%------------------------------------------------------------
% ivfhe_query: Make some queries
%   ids: vectors identifiers
%   idx: quantization cell
%   codes:  binary code (int uint8 format)
function matches = ivfhe_query (ivfhe, ids, v, ht, vidx, codes)

if ~exist ('vidx')
  [vidx,dis] = ivfhe.quantizer (ivfhe.quantizer_params, v);
end

if ~exist ('codes')
  codes = ivfhe.binsign (ivfhe, v, vidx);
end

matches = yael_ivf ('queryhe', int32(ids), int32(vidx), codes, ht);


%------------------------------------------------------------
% ivfhe_query_w: alternative implementation to weights the score
%   ids: vectors identifiers
%   idx: quantization cell
%   codes:  binary code (int uint8 format)
function [mids, msc] = ivfhe_queryw (ivfhe, ids, v, ht, vidx, codes)

if ~exist ('vidx')
  [vidx,dis] = ivfhe.quantizer (ivfhe.quantizer_params, v);
end

if ~exist ('codes')
  codes = ivfhe.binsign (ivfhe, v, vidx);
end

if isfield (ivfhe, 'scoremap') 
  if isfield (ivfhe, 'listw')
    [mids, msc] = yael_ivf ('queryhew', int32(ids), int32(vidx), codes, ht, ivfhe.scoremap, ivfhe.listw);
  else
    [mids, msc] = yael_ivf ('queryhew', int32(ids), int32(vidx), codes, ht, ivfhe.scoremap);
  end
else 
  [mids, msc] = yael_ivf ('queryhew', int32(ids), int32(vidx), codes, ht);
end

%------------------------------------------------------------
% ivfhe_getids: Get ids associated with a quantization cell
%   idx: quantization cell
function ids = ivfhe_getids (idx)

ids = yael_ivf ('getids', int32(idx));


%------------------------------------------------------------
% ivfhe_imbfactor: Compute the imbalance factor
function imf = ivfhe_imbfactor ()

imf = yael_ivf ('imbfactor');


%------------------------------------------------------------
% ivfhe_findbs: Get binary signatures associated with a quantization cell
% and particular ids
function bs = ivfhe_findbs (keys, ids)

bs = yael_ivf ('findbs', keys, int32(ids));


%------------------------------------------------------------
function ivfhe = ivfhe_load (fivf_name)

% Parameter file
ivfhe = load ([fivf_name '.mat'], '-mat', 'd', 'k', ...
              'nbits', 'Q', 'quantizer_params', 'medians', 'bin2compactbin');
yael_ivf ('free');
yael_ivf ('load', fivf_name);

% The methods associated with the ivfhe structure
ivfhe.quantizer = @yael_nn;

ivfhe.binsign = @ivfhe_binsign;
ivfhe.add = @ivfhe_add;
ivfhe.query = @ivfhe_query;
ivfhe.queryw = @ivfhe_queryw;
ivfhe.getids = @ivfhe_getids;
ivfhe.save = @ivfhe_save;
ivfhe.load = @ivfhe_load;
ivfhe.imbfactor = @ivfhe_imbfactor;
ivfhe.findbs = @ivfhe_findbs;


%------------------------------------------------------------
function ivfhe_save (ivfhe, fivf_name, quantizer)

% Parameter file (The matlab part)
save ([fivf_name '.mat'], '-mat', '-struct', 'ivfhe', 'd', 'k', ...
      'nbits', 'Q', 'quantizer_params', 'medians', 'bin2compactbin');

% Content of the inverted file
yael_ivf ('save', fivf_name);


