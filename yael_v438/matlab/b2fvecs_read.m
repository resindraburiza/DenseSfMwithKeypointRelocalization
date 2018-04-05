% Read a set of vectors stored in the bvec format (int + n * float)
% The function returns a set of output floating point vector (one vector per column)
%
% Syntax: 
%   v = b2fvecs_read (filename)        -> read all vectors
%   v = b2fvecs_read (filename, n)      -> read n vectors 
%   v = b2fvecs_read (filename, [a b]) -> read the vectors from a to b (indices starts from 1)
function v = b2fvecs_read (filename, bounds)

% open the file and count the number of descriptors
fid = fopen (filename, 'rb');
 
if fid == -1
  error ('I/O error : Unable to open the file %s\n', filename)
end

% Read the vector size
d = fread (fid, 1, 'int');

vecsizeof = 1 * 4 + d;

% Get the number of vectrors
fseek (fid, 0, 1);
a = 1;
bmax = ftell (fid) / vecsizeof;
b = bmax;

if nargin >= 2
  if length (bounds) == 1
    b = bounds;
   
  elseif length (bounds) == 2
    a = bounds(1);
    b = bounds(2);    
  end
end

assert (a >= 1);
if b > bmax
  b = bmax;
end

if b == 0 | b < a
  v = [];
  fclose (fid);
  return;
end

% compute the number of vectors that are really read and go in starting positions
n = b - a + 1;
a
(a-1)*vecsizeof

fseek (fid, (a - 1) * vecsizeof, -1);

fprintf ('b2fvecs_read -> pos=%d\n', ftell (fid));

% read n vectors
v = fread (fid, (d + 4) * n, 'uint8=>single');
v = reshape (v, d + 4, n);


% Check if the first column (dimension of the vectors) is correct
assert (sum (v (1, 2:end) == v(1, 1)) == n - 1);
assert (sum (v (2, 2:end) == v(2, 1)) == n - 1);
assert (sum (v (3, 2:end) == v(3, 1)) == n - 1);
assert (sum (v (4, 2:end) == v(4, 1)) == n - 1);
v = v (5:end, :);
  
fclose (fid);
