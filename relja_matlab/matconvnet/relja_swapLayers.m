%  net= relja_swapLayers(net, layerName1, layerName2, forceConsecutive)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function net= relja_swapLayers(net, layerName1, layerName2, forceConsecutive)
    if nargin<4, forceConsecutive= true; end
    
    i= relja_whichLayer(net, layerName1);
    j= relja_whichLayer(net, layerName2);
    assert(~forceConsecutive || i+1==j);
    temp= net.layers{i};
    net.layers{i}= net.layers{j};
    net.layers{j}= temp;
end
