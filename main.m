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
top_netvlad = 0; % matching the dense SfM based on netvlad score (not exhaustively)

% visualize only?
visualizeonly = false;

% reconstruct sparse?
reconstruct_sparse_colmap = true;

% do you want to relocalize or not at all?
global do_relocalize
do_relocalize = true;

% max image size for the network [width,height]
global maximsize
maximsize = [1600,1200];

% colmap_path. please comment out one of the colmap_path variable
% for colmap 3.3 or older
% colmap_path = '';

% for colmap 3.4 ['your_colmap_folder','colmap ']; -> you can leave it
% blank if your colmap is already in PATH dir
colmap_path = ['','colmap '];

% image path
pth = ['/media/aresindra/local/DenseSfMwithRelocalization/test_datasest/'];

% image_format
image_format = '.jpg'; % this is case sensitive
image_path = pth;
%%%%%%%%%%%% END OF OPTION %%%%%%%%%%%%

if ~visualizeonly
    at_run_colmap_w_densematching_c2f
    if reconstruct_sparse_colmap
        clear net
        reconstruct_sparse
    end
else
    imgs = {imagenames(:).name};
    N = length(imgs);
    visualization
end
