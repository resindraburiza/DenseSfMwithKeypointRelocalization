% This function writes a vector from a file in the libit format

function [v,d] = ivec_write (fid, v)


  
% first write the vector size
count = fwrite (fid, length(v), 'int');

if count ~= 1 
  error ('Unable to write vector dimension: count !=1 \n');
end

% write the vector components
count = fwrite (fid, v, 'int');

if count ~= length (v) 
  error ('Unable to write vector elements: count !=1 \n');
end

