function [f1,scale] = at_featureupsample(f1,fsz,isz)

 scale = isz(1:2)./fsz(1:2); % ratio between image size and number of points (check it)
%  if scale(1) ~= scale(2), keyboard; end
 f1 = scale(1)*f1;