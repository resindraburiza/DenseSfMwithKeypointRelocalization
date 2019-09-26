%  net= relja_swapLayersForEfficiency(net)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function net= relja_swapLayersForEfficiency(net)
    
    perm= 1:length(net.layers);
    
    iLayer= 1;
    
    while iLayer<length(net.layers)
        if strcmp(net.layers{iLayer}.type, 'relu') && ...
           strcmp(net.layers{iLayer+1}.type, 'pool') && strcmp(net.layers{iLayer+1}.method, 'max')
            perm(iLayer)= iLayer+1;
            perm(iLayer+1)= iLayer;
            iLayer= iLayer+2;
        else
            iLayer= iLayer+1;
        end
    end
    
    net.layers= net.layers(perm);
end
