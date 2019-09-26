%  layerTypes= relja_layerTypes(net)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function layerTypes= relja_layerTypes(net)
    layerTypes= cellfun(@(x) x.type, net.layers, 'UniformOutput', false);
end
