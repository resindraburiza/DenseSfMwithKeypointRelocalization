% Author: Relja Arandjelovic (relja@relja.info)

function vlad= computeVLAD(descs, cents, kdtree)
    if nargin<3
        kdtree= vl_kdtreebuild(cents);
    end
    
    k= size(cents, 2);
    n= size(descs, 2);
    
    nn= vl_kdtreequery(kdtree, cents, descs) ;
    assigns= zeros(k, n, 'single');
    assigns(sub2ind(size(assigns), double(nn), 1:length(nn)))= 1;
    
    vlad= vl_vlad(descs, cents, assigns, 'NormalizeComponents');
    
end
