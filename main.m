clear all
close all
reset(gpuDevice())

coarselayerlevel = 4;
finelayerlevel = 3;
finerlayerlevel = 1;

% define how you want to limit the match
min_matches = 0; % leave it zero if we want to use all matches
top = 0; % how many topN matches would you keep? leave it zero if all pair will be used

% visualize only?
visualizeonly = false;

pth = '/mnt/extensionHDD/DenseSfMwithRelocalization/test_datasest/';
image_format = '.jpg'; % this is case sensitive
image_path = pth;
loc_path = [pth 'colmap/'];

imagenames = dir(fullfile(image_path,['*',image_format])); 

% working directory
database_path = fullfile(loc_path,'database.db');
image_list_path = fullfile(loc_path,'imglist.txt');

feature_path = fullfile(pth,'features_reloc/');
match_path = fullfile(pth,'matches_reloc/');
match_list_path = fullfile([match_path],'colmap_matches.txt');

if ~visualizeonly
    at_run_colmap_w_densematching_c2f
else
    imgs = {imagenames(:).name};
    N = length(imgs);
    visualization
end