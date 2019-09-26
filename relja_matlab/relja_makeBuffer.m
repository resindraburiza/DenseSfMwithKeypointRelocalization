%  [buffer, bufferSize]= relja_makeBuffer(x, memLimitMB)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function [buffer, bufferSize]= relja_makeBuffer(x, memLimitMB)
    featDim= numel(x);
    sizePerVector= whos('x');
    bufferSize= max(1, floor(memLimitMB* 1e6/sizePerVector.bytes));
    buffer= zeros(featDim, bufferSize, class(x));
end
