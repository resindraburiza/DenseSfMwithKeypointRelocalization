% Author: Relja Arandjelovic (relja@relja.info)

function descs= extractDescs(fn)
    im= imread(fn);
    [~, descs]= vl_phow(im2single(im));
    descs= relja_rootsift(single(descs));
end
