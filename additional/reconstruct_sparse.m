dirgen(loc_path_sparse);

database_path_sparse = [loc_path_sparse 'database_sparse.db'];
cmd = sprintf('%sfeature_extractor --database_path ''%s'' --image_path ''%s''',...
    colmap_path, database_path_sparse, image_path);
system(cmd);

cmd = sprintf('%sexhaustive_matcher --database_path ''%s''',...
    colmap_path, database_path_sparse);
system(cmd);

cmd = sprintf('%smapper --database_path ''%s'' --image_path ''%s'' --export_path ''%s'' --Mapper.multiple_models 0 --Mapper.ba_refine_focal_length 0 --Mapper.ba_refine_extra_params 0',...
    colmap_path, database_path_sparse, image_path, loc_path_sparse);
system(cmd);

if ~exist(fullfile([loc_path_sparse '0/'],'images.txt'),'file')
    cmd = sprintf('%smodel_converter --input_path ''%s'' --output_path ''%s'' --output_type ''TXT''',...
        colmap_path, [loc_path_sparse '0/'], [loc_path_sparse '0/']);
    system(cmd);
end

cmd = sprintf('%smodel_analyzer --path ''%s''',...
        colmap_path, [loc_path_sparse '0/']);
[~,output] = system(cmd);
file = fopen([loc_path_sparse '0/model_properties.txt'],'w');
fprintf(file,output);
fclose(file);