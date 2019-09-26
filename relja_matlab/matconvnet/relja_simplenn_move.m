%  net= relja_simplenn_move(net, destination)
%
%  Author: Relja Arandjelovic (relja@relja.info)

% Copyright (C) 2015 Relja Arandjelovic.
% Portions Copyright (C) 2014 Andrea Vedaldi.
% All rights reserved.

function net= relja_simplenn_move(net, destination)
    moveToGPU= strcmp(destination, 'gpu');
    assert(moveToGPU || strcmp(destination, 'cpu'));
    
    if ~isfield(net, 'onGPU') || xor(net.onGPU, moveToGPU)
        net= modified_vl_simplenn_move(net, destination);
    end
    
    net.onGPU= moveToGPU;
end



function net = modified_vl_simplenn_move(net, destination)
% Relja Arandjelovic modified the function found in matconvnet
% 
% VL_SIMPLENN_MOVE  Move a simple CNN between CPU and GPU
%    NET = VL_SIMPLENN_MOVE(NET, 'gpu') moves the network
%    on the current GPU device.
%
%    NET = VL_SIMPLENN_MOVE(NET, 'cpu') moves the network
%    on the CPU.

switch destination
  case 'gpu', moveop = @(x) gpuArray(x) ;
  case 'cpu', moveop = @(x) gather(x) ;
  otherwise, error('Unknown desitation ''%s''.', destination) ;
end
for l=1:numel(net.layers)
  switch net.layers{l}.type
    case {'conv', 'bnorm'}
      for f = {'filters', 'biases', 'filtersMomentum', 'biasesMomentum'}
        f = char(f) ;
        if isfield(net.layers{l}, f)
          net.layers{l}.(f) = moveop(net.layers{l}.(f)) ;
        end
      end
      for f = {'weights', 'momentum'}
        f = char(f) ;
        if isfield(net.layers{l}, f)
          for j=1:numel(net.layers{l}.(f))
            net.layers{l}.(f){j} = moveop(net.layers{l}.(f){j}) ;
          end
        end
      end
    case {'custom'}
        if ismethod(net.layers{l}, 'move')
            net.layers{l}.move(moveop);
        else
            for f = {'weights', 'momentum'}
                f = char(f) ;
                if isfield(net.layers{l}, f) || isprop(net.layers{l}, f)
                    for j=1:numel(net.layers{l}.(f))
                        net.layers{l}.(f){j} = moveop(net.layers{l}.(f){j}) ;
                    end
                end
            end
        end
    otherwise
      % nothing to do ?
  end
end
end
