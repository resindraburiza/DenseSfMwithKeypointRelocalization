% This function reads the parameters of a gmm file
% 
% Usage: [w, mu, sigma] = gmm_read (filename)
function [w, mu, sigma] = gmm_read (filename)

% open the file and count the number of descriptors
fid = fopen (filename, 'rb');
 
if fid == -1
  error ('I/O error : Unable to open the file %s\n', filename)
end


% first read the vector size and the number of centroids
d = fread (fid, 1, 'int');
k = fread (fid, 1, 'int');

% read the elements
w = fread (fid, k, 'float=>single');
mu = fread (fid, d*k, 'float=>single');
sigma = fread (fid, d*k, 'float=>single');

mu = reshape (mu, d, k);
sigma = reshape (sigma, d, k);

fclose (fid);
