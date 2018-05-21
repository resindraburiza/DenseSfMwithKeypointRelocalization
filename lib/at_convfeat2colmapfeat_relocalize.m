function at_convfeat2colmapfeat_relocalize(net,img_pth,imfn,feat_pth,finerlayerlevel,coarselayerlevel,finelayerlevel)
global do_relocalize
if nargin < 4, finelayerlevel=3; end

[head1, tail1] = str_cut(imfn,'.');
f1cnn_matlabfn = fullfile(feat_pth,[head1 '.mat']);

f1siftfn = fullfile(feat_pth,[imfn '.txt']);

if ~exist(f1siftfn,'file')
    if ~exist(f1cnn_matlabfn,'file')
        if nargin < 7
            cnn = at_serialAllFeats_convfeat_sfm(net, img_pth, feat_pth, imfn, coarselayerlevel, 'useGPU', true);
        else
            %         cnn = at_serialAllFeats_convfeat_sfm(net, img_pth, imfn, [coarselayerlevel finelayerlevel], 'useGPU', true);
            cnn = at_serialAllFeats_convfeat_sfm(net, img_pth, feat_pth, imfn, [coarselayerlevel:-1:finerlayerlevel], 'useGPU', true);
        end
        dirgen(f1cnn_matlabfn);
        save('-v6',f1cnn_matlabfn,'cnn');
    else
        load(f1cnn_matlabfn,'cnn');
    end
    
    if nargin < 7
        cnn1 = cnn{coarselayerlevel}.x;
    else
        cnn1 = cnn{finelayerlevel}.x;
    end
    
    [desc1, f1] = at_cnnfeat2vlfeat(cnn1);
    %     cnnfeatfiner = cnn{finerlayerlevel}.x;
    
    
    cnnlayer = cell(1,finelayerlevel);
    
    % for L2normalization relocalization
    cnnfeatfiner = load(fullfile(feat_pth,['upsampled/' head1 '_upsampled.mat']));
    cnnfeatfiner = cnnfeatfiner.cnn;
    cnnfinersize = size(cnnfeatfiner);
    
    cnnfeatfiner = reshape(cnnfeatfiner,[cnnfinersize(1)*cnnfinersize(2) cnnfinersize(3)]);
    cnnfeatfiner = vecnorm(cnnfeatfiner,2,2);
    cnnfeatfiner = reshape(cnnfeatfiner,[cnnfinersize(1) cnnfinersize(2)]);
    cnnlayer(end) = {cnnfeatfiner};
    
    for i = finerlayerlevel:1:finelayerlevel-1
        tmp = cnn{i}.x;
        tmpsize = size(tmp);
        
        tmp = reshape(tmp,[tmpsize(1)*tmpsize(2) tmpsize(3)]);
        tmp = vecnorm(tmp,2,2);
        tmp = reshape(tmp,[tmpsize(1) tmpsize(2)]);
        cnnlayer(finelayerlevel-i) = {tmp};
    end

    if do_relocalize
        f1 = relocalize_coarse2fine(f1,cnnlayer);
    end
    save('-v6',fullfile(feat_pth,[head1 '_relocalize.mat']),'f1');
    im1 = imread(fullfile(img_pth,imfn));
    if do_relocalize
        [f1,s1] = at_featureupsample(f1,size(cnnfeatfiner),size(im1));
    else
        [f1,s1] = at_featureupsample(f1,size(cnn1),size(im1));
    end
    fp = fopen(f1siftfn,'w');
    dd = ones(1,128);
    fprintf(fp,'%d 128\n',size(f1,2));
    for jj=1:size(f1,2)
        fprintf(fp,'%f %f %f 0',f1(1,jj),f1(2,jj),s1(1));
        fprintf(fp,' %d',dd);
        fprintf(fp,'\n');
    end
    
    fclose(fp);
    
end
end

