%  net= relja_cropToLayer(net, layerName)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function net= relja_cropToLayer(net, layerName)
    net.layers= net.layers(1:relja_whichLayer(net, layerName));
end
