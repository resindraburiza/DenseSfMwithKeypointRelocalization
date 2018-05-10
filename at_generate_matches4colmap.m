function at_generate_matches4colmap(ii,imgs,feat_pth,match_pth,min_match,graph,score,finerlayer,coarselayerlevel,finelayerlevel)

N = length(imgs);
[head1, tail1] = str_cut(imgs{ii},'.');
f1cnn_matchfn = fullfile(match_pth,[head1 '.match.mat']);
Information = table;
Information.EndNodes = {};
Information.Homography = {};
Information.Inlier_idx = {};

if ~exist(f1cnn_matchfn,'file')
    matches = cell(1,N);
    inliers = cell(1,N);
    
    f1cnn_matlabfn = fullfile(feat_pth,[head1 '.mat']);
    r = load(f1cnn_matlabfn);
    cnn1 = r.cnn;
    for jj=ii+1:N
        if jj<ii
            continue;
        end
        [head2, tail2] = str_cut(imgs{jj},'.');
        f2cnn_matlabfn = fullfile(feat_pth,[head2 '.mat']);
        r = load(f2cnn_matlabfn);
        cnn2 = r.cnn;
        
        if nargin < 10
            tic
            cnnfeat1 = cnn1{coarselayerlevel}.x;
            cnnfeat2 = cnn2{coarselayerlevel}.x;
            [desc1, f1] = at_cnnfeat2vlfeat(cnnfeat1);
            [desc2, f2] = at_cnnfeat2vlfeat(cnnfeat2);
            match12 = at_dense_tc(desc1,desc2);
            [inls12, H, idx] = at_denseransac(f1,f2,match12,2);
            toc
        else
            tic
            [match12,f1,f2,cnnfeat1,cnnfeat2] = at_coarse2fine_matching_ext(cnn1,cnn2,coarselayerlevel,finelayerlevel);
            f1 = load(fullfile(feat_pth,[head1 '_relocalize.mat']));
            f1 = f1.f1;
            [~,idx1] = findunique(f1);
            f2 = load(fullfile(feat_pth,[head2 '_relocalize.mat']));
            f2 = f2.f1;
            [~,idx2] = findunique(f2);
            match12 = refinematch(match12,idx1,idx2);
            [inls12, H, idx] = at_denseransac(f1,f2,match12,5);
            toc
        end
        
        if min_match ~= 0
            if size(inls12,2)>min_match
                matches{jj} = match12;
                inliers{jj} = inls12;
            else
                matches{jj} = [];
                inliers{jj} = [];
            end
        else
            matches{jj} = match12;
            inliers{jj} = inls12;
        end
        
        New = {{graph.Nodes.Name{ii} graph.Nodes.Name{jj}},{H}, {idx}};
        Information = [Information; New];
    end
    
    dirgen(f1cnn_matchfn)
    save('-v6',f1cnn_matchfn,'matches','inliers','Information');
end
end

function [f1,idx] = findunique(f1)
f1_proc = f1';
[f1_proc,idx,~] = unique(f1_proc,'rows','stable');
f1 = f1_proc';
end

function [match] = refinematch(match12,idx1,idx2)
match1 = match12(1,:);
idx = ismember(match1,idx1);
match12 = match12(:,idx);
match2 = match12(2,:);
idx = ismember(match2,idx2);
match12 = match12(:,idx);
match = match12;
end