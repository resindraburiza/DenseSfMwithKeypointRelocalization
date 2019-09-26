%  [outDim, sz]= relja_netOutputDim(net, imDim)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function [outDim, sz]= relja_netOutputDim(net, imDim)
    % there must be a neater way to compute it, but who cares
    % as long as this is not executed often
    
    if nargin<2
        im= single(net.meta.normalization.averageImage);
    else
        if length(imDim)>3
            im= single(imDim);
        else
            im= zeros(imDim, 'single');
        end
    end
    
    if isfield(net, 'onGPU') && net.onGPU
        im= gpuArray(im);
    end
    
    res= vl_simplenn(net, im);
    outDim= numel(res(end).x);
    sz= size(res(end).x);
end
