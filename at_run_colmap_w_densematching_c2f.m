if ~exist('net','var')
    net = load('vd16_pitts30k_conv5_3_vlad_preL2_intra_white.mat');
    net = net.net;
    net= relja_simplenn_tidy(net);
    net= relja_cropToLayer(net, 'preL2');
    net= relja_simplenn_move(net, 'gpu');
    net.onGPU= true;
end

imgs = {imagenames(:).name};
N = length(imgs);

% to store homography matrix
G = graph(zeros(N),imgs);
G.Edges.Weight = [];

database_path = fullfile(loc_path,'database.db');
image_list_path = fullfile(loc_path,'imglist.txt');

feature_path = fullfile(pth,'features_reloc/');
match_path = fullfile(pth,'matches_reloc/');
match_list_path = fullfile([match_path],'colmap_matches.txt');

if ~exist(match_list_path,'file')
    
    for ii=1:N
        disp(['image number: ' num2str(ii)]);
        at_convfeat2colmapfeat_relocalize(net,image_path,imgs{ii},feature_path,finerlayerlevel,coarselayerlevel,finelayerlevel);
    end
    
    parfor ii=1:N-1
        at_generate_matches4colmap(ii,imgs,feature_path,match_path,min_matches,G,[],finerlayerlevel,coarselayerlevel,finelayerlevel);
    end
    
    if top > 0
        topN(match_path,imgs,top);
    end
    
    fp = fopen(match_list_path,'w');
    for ii=1:N-1
        [head1, tail1] = str_cut(imgs{ii},'.');
        if top == 0
            f1cnn_matchfn = fullfile([match_path],[head1 '.match.mat']);
            
        else
            f1cnn_matchfn = fullfile([match_path '/processed'],[head1 '.match.mat']);
        end
        load(f1cnn_matchfn,'inliers','matches');
        fn1 = imgs{ii};
        
        for jj=ii+1:N
            if ~isempty(inliers{jj})
                inls = inliers{jj};
                fn2 = imgs{jj};
                fprintf(fp,'%s %s\n',fn1,fn2);
                
                [~,ia] = unique(inls(1,:));
                inls = inls(:,ia);
                [~,ib] = unique(inls(2,:));
                inls = inls(:,ib);
                
                fprintf(fp,'%d %d\n',inls-1);
                fprintf(fp,'\n');
                
            end
        end
    end
    fclose(fp);
end

import_path = loc_path;
export_path = fullfile(loc_path,'0/');

if ~exist(fullfile(export_path,'images.txt'),'file')
    dirgen(import_path);
    
    % 1. feature import -- database
    fplist = fopen(image_list_path,'w');
    for ii=1:N
        fprintf(fopen('list.tmp','w'),'%s',imgs{ii});
        fprintf(fplist,'%s\n',imgs{ii});
        cmd = sprintf('feature_importer --database_path ''%s'' --image_path ''%s'' --import_path ''%s'' --image_list_path ''list.tmp'' --SiftExtraction.upright 1 --SiftExtraction.max_num_orientations 1 --SiftExtraction.gpu_index 0', ...
            database_path, image_path, feature_path);
        system(cmd);
    end
    fclose(fplist);
    
    %  2. feature match loading
    cmd = sprintf('matches_importer --database_path ''%s'' --match_list_path ''%s'' --match_type ''inliers''', ...
        database_path, match_list_path);
    system(cmd);
    
    cmd = sprintf('mapper --database_path ''%s'' --image_path ''%s'' --image_list_path ''%s'' --export_path ''%s'' --Mapper.multiple_models 0 --Mapper.ba_refine_focal_length 0 --Mapper.ba_refine_extra_params 0', ...
        database_path, image_path, image_list_path, import_path);
    system(cmd);
    
    cmd = sprintf('model_converter --input_path ''%s'' --output_path ''%s'' --output_type ''TXT''', export_path, export_path);
    system(cmd);
    
end

