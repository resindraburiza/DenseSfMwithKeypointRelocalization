%  relja_netSave(net)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function relja_netSave(net, fn)
    origGPU= isfield(net, 'onGPU') && net.onGPU;
    
    if origGPU
        net= relja_simplenn_move(net, 'cpu');
    end
    
    % -v7.3 prevents from calling this twice - remember to save the original file that way too
    if exist(fn, 'file')
        save( fn, 'net', '-append'); % -v7.3 is default with append
    else
        save( fn, 'net', '-v7.3');
    end
    
    if origGPU
        % needed because if a layer is a handle class, it would remain modified
        net= relja_simplenn_move(net, 'gpu');
    end
end
