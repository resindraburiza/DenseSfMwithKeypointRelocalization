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

function cnnfeat = at_serialAllFeats_convfeat_sfm(net, imPath, feat_path, imageFns, outputlayer, varargin)
opts= struct(...
    'useGPU', true, ...
    'numThreads', 12, ...
    'batchSize', 1 ...
    );
opts= vl_argparse(opts, varargin);

if opts.useGPU
    network = net;
end

simpleNnOpts= {'conserveMemory', false, 'mode', 'test'};

relja_display('cnn desciption: Start');

if opts.useGPU
    network= relja_simplenn_move(network, 'gpu');
end

thisImageFns= fullfile( imPath, imageFns );

ims = single(imread(thisImageFns));

% fix non-colour images
if size(ims,3)==1
    ims= cat(3,ims,ims,ims);
end

ims_proper(:,:,1)= ims(:,:,1) - network.meta.normalization.averageImage(1,1,1);
ims_proper(:,:,2)= ims(:,:,2) - network.meta.normalization.averageImage(1,1,2);
ims_proper(:,:,3)= ims(:,:,3) - network.meta.normalization.averageImage(1,1,3);

ims_proper = at_imageresize(ims_proper,1600,1200);
ims = gpuArray(ims_proper);
% --extract features
res = vl_simplenn(network, ims, [], [], simpleNnOpts{:});


cnnfeat = cell(1,5);

for thislayer = 1:length(outputlayer)
    switch outputlayer(thislayer)
        case 5
            cnnfeat{5}.x = gather(res(31).x);
        case 4
            cnnfeat{4}.x = gather(res(25).x);
        case 3
            cnnfeat{3}.x = gather(res(18).x);
        case 2
            cnnfeat{2}.x = gather(res(11).x);
        case 1
            cnnfeat{1}.x = gather(res(6).x);
    end
end

% extract conv1_2
[head1, tail1] = str_cut(imageFns,'.');
f1cnn_matlabfn = [feat_path 'upsampled/' head1 '_upsampled.mat'];
dirgen(f1cnn_matlabfn);
cnn = gather(res(4).x);
save('-v6',f1cnn_matlabfn,'cnn');

clear res;

relja_display('cnn desciption: End');

end
