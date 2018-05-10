clear all
close all
reset(gpuDevice())

coarselayerlevel = 4;
finelayerlevel = 3;
finerlayerlevel = 1;

%%%%%%%%%%%% OPTION %%%%%%%%%%%%
% define how you want to limit the match
min_matches = 0; % leave it zero if we want to use all matches
top = 0; % how many topN matches would you keep? leave it zero if all pair will be used

% visualize only?
visualizeonly = false;

% reconstruct sparse?
reconstruct_sparse_colmap = true;

% colmap_path. please comment out one of the colmap_path variable
% for colmap 3.3 or older
% colmap_path = '';

% for colmap 3.4 ['you_colmap_folder','colmap ']; -> you can leave it
% blank if your colmap is already in PATH dir
colmap_path = ['','colmap '];

% image path
pth = ['/mnt/extensionHDD/DenseSfMwithRelocalization/test_datasest/'];

% image_format
image_format = '.jpg'; % this is case sensitive
image_path = pth;
%%%%%%%%%%%% END OF OPTION %%%%%%%%%%%%

if ~visualizeonly
    at_run_colmap_w_densematching_c2f
    if reconstruct_sparse_colmap
        reconstruct_sparse
    end
else
    imgs = {imagenames(:).name};
    N = length(imgs);
    visualization
end
