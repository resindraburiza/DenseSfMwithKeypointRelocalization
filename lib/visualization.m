imagenames = dir(fullfile(image_path,['*',image_format]));
imgs = {imagenames(:).name};
N = length(imgs);
feature_path = fullfile(pth,'features_reloc/');
match_path = fullfile(pth,'matches_reloc/');


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
        if isempty(inliers{jj})
            continue
        end
        inls = inliers{jj};
        fn2 = imgs{jj};
        r = load(fullfile(feature_path,[imgs{ii}(1:end-4) '.mat']));
        cnn1 = r.cnn{finelayerlevel}.x;
        [desc1, f1] = at_cnnfeat2vlfeat(cnn1);
        f1 = load(fullfile(feature_path,[imgs{ii}(1:end-4) '_relocalize.mat']));
        im1 = imread(fullfile(image_path,fn1));
        multiplier = size(im1,1)/size(cnn1,1);
        f1 = at_featureupsample(f1.f1,size(cnn1)*multiplier,size(im1));
        
        r = load(fullfile(feature_path,[imgs{jj}(1:end-4) '.mat']));
        cnn2 = r.cnn{finelayerlevel}.x;
        [desc2, f2] = at_cnnfeat2vlfeat(cnn2);
        f2 = load(fullfile(feature_path,[imgs{jj}(1:end-4) '_relocalize.mat']));
        im2 = imread(fullfile(image_path,fn2));
        f2 = at_featureupsample(f2.f1,size(cnn2)*multiplier,size(im2));
        
        subfig(4,4,3);
        imshow(im1); hold on;
        plot(f1(1,inls(1,:)),f1(2,inls(1,:)),'g.');
        title([imgs{ii}]);
        %       plot(f1(1,matches{jj}(1,:)),f1(2,matches{jj}(1,:)),'g.');
        %         plot(f1(1,:),f1(2,:),'g.');
        
        subfig(4,4,4);
        imshow(im2); hold on;
        plot(f2(1,inls(2,:)),f2(2,inls(2,:)),'g.');
        title([imgs{jj}]);
        %       plot(f2(1,matches{jj}(1,:)),f2(2,matches{jj}(1,:)),'g.');
        %         plot(f2(1,:),f2(2,:),'g.');
        
        keyboard;
        close all
    end
end