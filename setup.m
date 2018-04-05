start_path = pwd;
addpath(start_path);
%--- Third party 
if ~exist('vl_version','file')
  run([start_path '/vlfeat-0.9.20/toolbox/vl_setup']);
end

run([start_path '/matconvnet_aristoteles/matlab/vl_setupnn']);
addpath([start_path '/netvlad/']);
addpath([start_path '/relja_matlab']);
addpath([start_path '/relja_matlab/matconvnet']);
addpath([start_path '/relja']);
addpath([start_path '/additional']);

switch computer
  case 'GLNXA64'
    addpath([start_path '/yael_v438/matlab']);    
  case 'MACI64'
    addpath([start_path '/yael_matlab_mac64_v438']);    
  otherwise
    error('Yael library is missing!')
end

if 0
paths= localPaths();
run( fullfile(paths.libMatConvNet, 'matlab', 'vl_setupnn.m') );
addpath( genpath(paths.libReljaMatlab) );
addpath( genpath(paths.libYaelMatlab) );
addpath('datasets/');
end

