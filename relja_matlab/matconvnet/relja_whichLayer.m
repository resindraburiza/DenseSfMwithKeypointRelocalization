%  iLayer= relja_whichLayer(net, layerName)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function iLayer= relja_whichLayer(net, layerName)
    layerNames= cellfun(@(x) x.name, net.layers, 'UniformOutput', false);
    iLayer= find(ismember(layerNames, layerName));
    assert(numel(iLayer)==1);
end
