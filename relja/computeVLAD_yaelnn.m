% Author: Relja Arandjelovic (relja@relja.info)

function vlad= computeVLAD_yaelnn(descs, cents)

k= size(cents, 2);
n= size(descs, 2);

[nn,dis] = yael_nn(cents,descs);
assigns= zeros(k, n, 'single');
assigns(sub2ind(size(assigns), double(nn), 1:length(nn)))= 1;

vlad= vl_vlad(descs, cents, assigns, 'NormalizeComponents');

end
