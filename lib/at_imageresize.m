function im1 = at_imageresize(im1,a,b)

isz = size(im1(:,:,1));
if (a*b) < prod(isz)
  if isz(1) > isz(2)
    im1 = imresize(im1,[a NaN]);
  else
    im1 = imresize(im1,[NaN a]);
  end
end

% isz = size(im1(:,:,1));
% if (1920*1440) < prod(isz)
%   if isz(1) > isz(2)
%     im1 = imresize(im1,[1920 NaN]);
%   else
%     im1 = imresize(im1,[NaN 1920]);
%   end
% end

% isz = size(im1(:,:,1));
% if (640*512) < prod(isz)
%   if isz(1) > isz(2)
%     im1 = imresize(im1,[640 NaN]);
%   else
%     im1 = imresize(im1,[NaN 640]);
%   end
% end

% isz = size(im1(:,:,1));
% if (1920*1440) < prod(isz)
%   im1 = imresize(im1,sqrt((1920*1440)/prod(isz)));
% end
