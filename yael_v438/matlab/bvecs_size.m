% Return the number of vectors contained in a bvecs files and their dimension
%
% Syntax:   [n,d] = bvecs_size (filename) 
function [n, d] = bvecs_size (filename)

% open the file and count the number of descriptors
fid = fopen (filename, 'rb');
 
if fid == -1
  error ('I/O error : Unable to open the file %s\n', filename)
end

% Read the vector size
d = fread (fid, 1, 'int');

% Read the number of vectors
fseek (fid, 0, 1);
n = ftell (fid) / (1 * 4 + d);
fseek (fid, 0, -1);

fclose (fid);
