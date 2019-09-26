%  layerNames= relja_layerNames(net)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function layerNames= relja_layerNames(net)
    layerNames= cellfun(@(x) x.name, net.layers, 'UniformOutput', false);
end
