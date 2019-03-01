function score = compute_similarity_netVLAD(pathToImageFolder, image_format)

scorefn = [pathToImageFolder '/score_netvlad_pitts30k.mat'];
netFn = 'vd16_pitts30k_conv5_3_vlad_preL2_intra_white.mat';

% pth = './data/';
% pathToImageFolder = [pth ''];
% q_pathToImageFolder = pathToImageFolder;
% scorefn = [q_pathToImageFolder 'score/score_netvlad_pitts30k.mat'];
% netFn = './vd16_pitts30k_conv5_3_vlad_preL2_intra_white.mat';

dbImageFn = fullfile(pathToImageFolder,'imgs.mat');
if ~exist(dbImageFn,'file')
    fnames = dir(fullfile(pathToImageFolder,['*',image_format]));
    imgs = {fnames(:).name};
    db.imgs = imgs;
    save('-v6',dbImageFn,'imgs');
else
    db = load(dbImageFn,'imgs');
end

dbFeatFn = [pathToImageFolder 'db_netvlad.mat'];
numDatabase = length(db.imgs);

% qFeatFn = [q_pathToImageFolder 'query_netvlad.mat'];
% query = load(fullfile(q_pathToImageFolder,'imgs.mat'));
% numQueries = length(query.imgs);

% load pre-computed net file
net = load(netFn);
net = net.net;
net= relja_simplenn_tidy(net);

if ~exist(dbFeatFn,'file')
  fprintf(1,'extracting database features\n');
  tstart = tic;
  dirgen(dbFeatFn);
  numberOfImagesInABatch = 1;
  serialAllFeats_query(net, pathToImageFolder, db.imgs, dbFeatFn,...
    'batchSize', numberOfImagesInABatch,'useGPU', true);
  fprintf(1,'Database building took %f sec\n',toc(tstart));
end

% if ~exist(qFeatFn,'file')
%   fprintf(1,'extracting query features\n');
%   tstart = tic;
%   dirgen(qFeatFn);
%   numberOfImagesInABatch = 1;
%   serialAllFeats_query(net, q_pathToImageFolder, query.imgs, qFeatFn,...
%     'batchSize', numberOfImagesInABatch);
%   fprintf(1,'query building took %f sec\n',toc(tstart));
% end

% compute similarity score
fprintf(1,'computing similarity scores\n');
if ~exist(scorefn,'file')
  tstart = tic;
  % load db features
  nDims = 2^12;
  dbFeat = fread( fopen(dbFeatFn, 'rb'), [nDims, numDatabase], 'float32=>single');
  
  score = dbFeat'*dbFeat;
  dirgen(scorefn);
  fprintf(1,'similarity computation took %f sec\n',toc(tstart));
  save('-v7.3',scorefn,'score');
else
  load(scorefn);
end
%figure; imagesc(score); axis image; 