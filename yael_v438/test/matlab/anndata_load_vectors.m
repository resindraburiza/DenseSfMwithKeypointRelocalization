% Generate or load an evaluation set (query+learn+base)
%
% This software is governed by the CeCILL license under French law and
% abiding by the rules of distribution of free software. 
% See http://www.cecill.info/licences.en.html

if (~exist ('knn'))
  knn = 100;
end

if ~exist ('datadir')
  error ('Datadir not defined');
end

if strcmp (dataset, 'random')
  % synthetic dataset
    d = 16;

    % Generate a set of unit norm vectors
    ntrain = 10000;
    nbase = 1000000; 
    nquery = 1000;
    vtrain = single (rand (d, ntrain));
    vbase = single (rand (d, nbase));
    vquery = single (rand (d, nquery)); 

    % Compute the ground-truth
    t0 = cputime;
    [ids_gnd, dis_gnd] = yael_nn (vbase, vquery, knn);
    tgnd = cputime - t0;
    
else
  switch dataset
   case 'siftsmall'
    basedir = [datadir '/siftsmall/'] ;  % modify this directory to fit your configuration
    fbase = [basedir 'siftsmall_base.fvecs'];
    fquery = [basedir 'siftsmall_query.fvecs'];
    ftrain = [basedir 'siftsmall_learn.fvecs'];
    fgroundtruth = [basedir 'siftsmall_groundtruth.ivecs'];

   case 'sift'
    basedir = [datadir '/sift/'] ;       % modify this directory to fit your configuration
    fbase = [basedir 'sift_base.fvecs'];
    fquery = [basedir 'sift_query.fvecs'];
    ftrain = [basedir 'sift_learn.fvecs'];
    fgroundtruth = [basedir 'sift_groundtruth.ivecs'];
    
   case 'gist'
    basedir = [datadir '/gist/'] ;       % modify this directory to fit your configuration
    fbase = [basedir 'gist_base.fvecs'];
    fquery = [basedir 'gist_query.fvecs'];
    ftrain = [basedir 'gist_learn.fvecs'];
    fgroundtruth = [basedir 'gist_groundtruth.ivecs'];
  end

  % Read the vectors
  vtrain = fvecs_read (ftrain);
  vbase  = fvecs_read (fbase);
  vquery = fvecs_read (fquery);
    
  ntrain = size (vtrain, 2);
  nbase = size (vbase, 2);
  nquery = size (vquery, 2);
  d = size (vtrain, 1);

  % Load the groundtruth
  ids = ivecs_read (fgroundtruth);
%  ids_gnd = ids (1, :) + 1;  % matlab indices start at 1
  ids_gnd = ids (1:knn, :) + 1;
end
