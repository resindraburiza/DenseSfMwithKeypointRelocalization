% This function reads a siftgeo binary file
%
% Usage: [v, meta] = siftgeo_read (filename)
%   filename    the input filename
%
% Returned values
%   v           the sift descriptors (1 descriptor per line)
%   meta        meta data for each descriptor, i.e., per line:
%               x, y, scale, angle, mi11, mi12, mi21, mi22, cornerness
function [v, meta] = siftgeo_read (filename, dv, maxn)

if nargin < 2, dv = 128; end

if nargin < 3, maxn = 10^9+1; end


% open the file and count the number of descriptors
fid = fopen (filename, 'r');

if fid==-1
  error('could not open %s',filename)
end

fseek (fid, 0, 1);
n = ftell (fid) / (9 * 4 + 1 * 4 + dv);
fseek (fid, 0, -1);

% first read the meta information associated with the descriptor
meta = zeros (9, n,'single');
v = zeros (dv, n, 'single');
d = 0;

% read the elements
for i = 1:n
  meta(:,i) = fread (fid, 9, 'float');
  d = fread (fid, 1, 'int');
  assert (d == dv);
  v(:,i) = fread (fid, d, 'uint8=>single');
end

fclose (fid);
