%  Uses the network `net` to extract image representations from a list
%  of image filenames `imageFns`.
%  `imageFns` is a cell array containing image file names relative
%  to the `imPath` (i.e. `[imPath, imageFns{i}]` is a valid JPEG image).
%  The representations are saved to `outFn` (single 4-byte floats).
%
%  Additional options:
%
%  `useGPU': Use the GPU or not
%
%  `batchSize': The number of images to process in a batch. Note that if your
%       input images are not all of same size (they are in place recognition
%       datasets), you should set `batchSize` to 1.

function ttt = at_dummy_netvlad(net, imfn)

simpleNnOpts= {'conserveMemory', true, 'mode', 'test'};

ims = single(imread(imfn));
  
if size(ims,3)==1
  ims= cat(3,ims,ims,ims);
end

ims(:,:,1)= ims(:,:,1) - net.meta.normalization.averageImage(1,1,1);
ims(:,:,2)= ims(:,:,2) - net.meta.normalization.averageImage(1,1,2);
ims(:,:,3)= ims(:,:,3) - net.meta.normalization.averageImage(1,1,3);
  
ims= gpuArray(ims);
  
isz = size(ims(:,:,1));
ims = at_imageresize(ims);
  
tstart = tic;
% ---------- extract features
res = vl_simplenn(net, ims, [], [], simpleNnOpts{:});
feats= gather(res(end).x);
ttt = toc(tstart);
