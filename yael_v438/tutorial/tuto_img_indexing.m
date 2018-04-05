%-------------------------------------------------------------------------
% Simple image indexing system in Matlab, as part of Yael's tutorial
%
% Hervé Jégou - % Copyright (c) Inria 2014. 
%-------------------------------------------------------------------------

addpath ('~/src/yael/matlab/');

% Vocabulary size. In practice, we would rather choose k=100k
k = 1024;                    

% Images and descriptors are assumed stored in the following directory
dir_data = './holidays_100/';

% Parameters For Hamming Embedding
nbits = 128;                 % Typical values are 32, 64 or 128 bits
ht = floor(nbits*24/64);     % Hamming Embedding threshold
scoremap = zeros (1, nbits+1);
scoremap(1:ht+1) = (1-(0:ht)/ht).^3;


%-------------------------------------------------------------------------
% Retrieve the image list and load the images and SIFT
%-------------------------------------------------------------------------

img_list = dir ([dir_data '/*.jpg']);
nimg = numel(img_list);


tic 
imgs = arrayfun (@(x) (imread([dir_data x.name])), img_list, 'UniformOutput', false) ;
fprintf ('* Loaded %d images in %.3f seconds\n', numel(imgs), toc); tic

[sifts, meta] = arrayfun (@(x) (siftgeo_read([dir_data strrep(x.name, '.jpg', '.siftgeo')])), ...
                                img_list, 'UniformOutput', false) ; 
nsifts = cellfun(@(x)(size(x,2)),sifts);
totsifs = sum(nsifts);

fprintf ('* Loaded %d descriptors in %.3f seconds\n', totsifts, toc); tic

sifts = cellfun (@(x) (yael_vecs_normalize(sign(x).*sqrt(abs(x)))), ...
                        sifts, 'UniformOutput', false) ;

fprintf ('* Convert to RootSIFT in %.3f seconds\n', toc); tic


%-------------------------------------------------------------------------
% Learn and build the image indexing structure
%-------------------------------------------------------------------------

% Here we learn it on Holidays itself to avoid requiring another dataset. 
% Note: this is bad practice and should be avoide. A proper evaluation 
%       should employ an external dataset for dictionary learning.

vtrain = [sifts{:}];
vtrain = vtrain (:, 1:2:end);

C = yael_kmeans (vtrain, k, 'niter', 10); 
fprintf ('* Learned a visual vocabulary C in %.3f seconds\n', toc); tic

% We provide the codebook and the function that performs the assignment,  
% here it is the exact nearest neighbor function yael_nn

ivfhe = yael_ivf_he (k, nbits, vtrain, @yael_nn, C);
fprintf ('* Learned the Hamming Embedding structure in %.3f seconds\n', toc); tic

% Add all the descriptors to the inverted file. Each descriptor receive 
% an identifier, which can be translated to an image by the next variable.
% We also compute a normalization factor
imnorms = zeros (nimg, 1);
lastid = 0;
descid_to_imgid = zeros (totsifts, 1);  % desc to image conversion
imgid_to_descid = zeros (nimg, 1);      % for finding desc id 
t0 = cputime;
for i = 1:nimg
  
  ndes = nsifts(i);  % number of descriptors
  
  % Add the descriptors to the inverted file. 
  % The function returns the visual words (and binary signatures), 
  % from which we can compute the normalization factor of the image
  [vw,bits] = ivfhe.add (ivfhe, lastid+(1:ndes), sifts{i});
  imnorms(i) = norm(hist(vw,1:k));
  descid_to_imgid(lastid+(1:ndes)) = i; 
  imgid_to_descid(i) = lastid;
  lastid = lastid + ndes;
end
fprintf ('* Quantization, bitvectors computed and added to IVF in %.3fs\n',  cputime-t0);


%-------------------------------------------------------------------------
% I/O for the inverted files
%-------------------------------------------------------------------------

% Save inverted file filename on disk
fivf_name = 'holidays100.ivf'; 
fprintf ('* Save the inverted file to %s\n', fivf_name);
ivfhe.save (ivfhe, ivfname);

% Free the variables associated with the inverted file
fprintf ('* Free the inverted file\n');
yael_ivf ('free');
clear ivfhe;

% Load ivf
fprintf ('* Load the inverted file from %s\n', fivf_name);
ivfhe = yael_ivf_he (fivf_name);


%-------------------------------------------------------------------------
% Compute the scores and show images
%-------------------------------------------------------------------------
Queries = [1 13 23 42 63 83];
nq = numel (Queries);
nshow = 6;


% Configure the drawing zone
phandler = zeros (nshow, 1);  
figure('Position', [sz(3)/8 sz(4)/2 sz(3)*3/4 sz(4)/3]); 
for q = 1:nq
  for pl = 1:nshow
    phandler(q, pl) = subplot('Position', [(pl-1)/nshow 0 0.99/nshow 1]); 
  end
end


for q = 1:nq
  qimg = Queries(q)

  matches = ivfhe.query (ivfhe, int32(1:nsifts(qimg)), sifts{qimg}, ht);
  fprintf ('* %d Queries performed in %.3f seconds -> %d matches\n', nsifts(qimg), toc,  size (matches, 2));

  % Translate to image identifiers and count number of matches per image, 
  m_imids = descid_to_imgid(matches(2,:));
  n_immatches = hist (m_imids, 1:nimg);

  % Now, take into account the strength of the matches
  n_imscores = accumarray (m_imids, scoremap (matches(3,:)+1)', [nimg 1]) ./ (imnorms+0.00001);

  % Images are ordered by descreasing score
  [~, idx] = sort (n_imscores, 'descend');
  
  % We assume that the first image is the query itself (warning!)
  sz = get (0, 'ScreenSize');
  subplot(phandler(1,1)), imagesc(imgs{idx(1)}); 
  s = sprintf('Query -> %d descriptors', size(sifts{idx(1)}, 2));
  title (s); axis off image
  
  for s = 2:nshow
    subplot(phandler(1,s)), imagesc(imgs{idx(s)}); axis off image; hold on;
    str = sprintf ('%d matches \n score %.3f', n_immatches(idx(s)), 100*n_imscores(idx(s)));
    title (str); 

    % Display the matches
    mids = matches (2, find (m_imids == idx(s))) - imgid_to_descid(idx(s));

    plot(meta{idx(s)}(1,:),meta{idx(s)}(2,:),'r.');
    plot(meta{idx(s)}(1,mids),meta{idx(s)}(2,mids),'y.'); 
    hold off;
  end
  pause
end
close;




