function [match12, feat1fine, feat2fine, cnnfeat1fine, cnnfeat2fine] = at_coarse2fine_matching_ext(cnn1,cnn2,coarselayerlevel,finelayerlevel,skiplevel)
if nargin < 5, skiplevel = 1; end

match12 = [];
method = 'new';

for thislevel = coarselayerlevel:-skiplevel:finelayerlevel+1
    cnnfeat1 = cnn1{thislevel}.x;
    cnnfeat2 = cnn2{thislevel}.x;
    
    cnnsize1 = size(cnnfeat1(:,:,1));
    cnnsize2 = size(cnnfeat2(:,:,2));
    
    cnnfeat1fine = cnn1{thislevel-skiplevel}.x;
    cnnfeat2fine = cnn2{thislevel-skiplevel}.x;
    
    cnnfinesize1 = size(cnnfeat1fine(:,:,1));
    cnnfinesize2 = size(cnnfeat2fine(:,:,1));
    
    [desc1, feat1] = at_cnnfeat2vlfeat(cnnfeat1);
    [desc2, feat2] = at_cnnfeat2vlfeat(cnnfeat2);
    
    [desc1fine, feat1fine] = at_cnnfeat2vlfeat(cnnfeat1fine);
    [desc2fine, feat2fine] = at_cnnfeat2vlfeat(cnnfeat2fine);
    
    if thislevel == coarselayerlevel
        match12 = at_dense_tc(desc1,desc2);
    end
    
    % fine level position is
    if strcmp(method,'old')
        [hash_table1, hash_coarse1] = at_dense_hashtable(cnnfeat1,cnnfeat1fine);
        [hash_table2, hash_coarse2] = at_dense_hashtable(cnnfeat2,cnnfeat2fine);
    end
    newmatch = cell(1,size(match12,2));
    for ii=1:size(match12,2)
        if strcmp(method,'old')
            [d1,f1,ind1] = at_retrieve_fineposition(hash_coarse1,hash_table1,feat1(:,match12(1,ii)),desc1fine,feat1fine,cnnfinesize1);
            [d2,f2,ind2] = at_retrieve_fineposition(hash_coarse2,hash_table2,feat2(:,match12(2,ii)),desc2fine,feat2fine,cnnfinesize2);
        else
            [d1,f1,ind1] = at_retrieve_fineposition_simple(feat1(:,match12(1,ii)),desc1fine,feat1fine,cnnfinesize1,cnnsize1,skiplevel);
            [d2,f2,ind2] = at_retrieve_fineposition_simple(feat2(:,match12(2,ii)),desc2fine,feat2fine,cnnfinesize2,cnnsize2,skiplevel);
        end
        thismatch12 = at_dense_tc(d1,d2);
        newmatch{ii} = [ind1(thismatch12(1,:)); ind2(thismatch12(2,:))];
    end
    match12 = [newmatch{:}];
end


% % --- compute similarity (matching NN score)
% % [match12,inls12] = at_denseransac(desc1,f1,desc2,f2);
%
end

function [d1,f1,ind1] = at_retrieve_fineposition_simple(feat1,desc1fine,feat1fine,cnnsizefine,cnnsize,skiplevel)
Neigh = 1;
x = feat1(2,:);
y = feat1(1,:);

xmin = max(1,x-Neigh);
xmax = min(cnnsize(1),x+Neigh);
ymin = max(1,y-Neigh);
ymax = min(cnnsize(2),y+Neigh);

xdiff = xmax-xmin+1;
ydiff = ymax-ymin+1;

xfineloc = xmin*(2^skiplevel)-(2^skiplevel-1);
yfineloc = ymin*(2^skiplevel)-(2^skiplevel-1);

xrange = xfineloc:1:(xfineloc+2*xdiff-1);
yrange = yfineloc:1:(yfineloc+2*ydiff-1);

ind1 = zeros(1,length(xrange)*length(yrange));
xrangemodif = repelem(xrange,length(yrange));
yrangemodif = repmat(yrange,1,length(xrange));

pairs = [xrangemodif' yrangemodif'];

for i=1:length(ind1)
    ind1(i) = (pairs(i,2)-1)*cnnsizefine(1)+pairs(i,1);
end

d1 = desc1fine(:,ind1);
f1 = feat1fine(:,ind1);

end

function [d1,f1,ind1] = at_retrieve_fineposition(hash_coarse1,hash_table1,feat1,desc1fine,feat1fine,sizeF)

Neigh = 1; % making it 2 could give us more features

x = feat1(2,:);
y = feat1(1,:);

xmin = max(1,x-Neigh);
xmax = min(size(hash_coarse1,1),x+Neigh);
ymin = max(1,y-Neigh);
ymax = min(size(hash_coarse1,2),y+Neigh);

[x_nb,y_nb] = meshgrid(xmin:xmax,ymin:ymax);
x_nb = x_nb(:); y_nb = y_nb(:);

pos1 = hash_coarse1(x_nb,y_nb);
sub1 = [hash_table1{pos1}];
ind1 = sub2ind(sizeF,sub1(2,:),sub1(1,:));

d1 = desc1fine(:,ind1);
f1 = feat1fine(:,ind1);
end