% Generic way to load files depending on the type (determined by extension)
%
function [X,Y] = load_ext (filename, nrows, bounds, verbose)

% Retrieve the extension of the file
ext = regexp (filename, '\.(\w)*$');
if length(ext) == 0
  error ('The filename should have an extension');
end
ext = filename (ext:end);

nmin = 1;
nmax = inf;

% Default
Y = [];
if ~exist('verbose'), verbose = false; end;
if ~exist('bounds'),
  nmin = 1;
  nmax = inf;
elseif size (bounds, 2) == 2
  nmin = bounds(1);
  nmax = bounds(2) - bounds(1) + 1;
elseif size (bounds, 2) == 1
  nmin = 1;
  nmax = bounds;
end


switch ext
 case '.siftgeo'
  if ~exist('nrows'), nrows = 128; end;

  if verbose, fprintf ('< load siftgeo file %s\n', filename); end
  if nmax == Inf,   [X, Y] = siftgeo_read (filename, nrows);
  elseif nmin == 1, [X, Y] = siftgeo_read (filename, nrows, nmax);
  else error ('### This call of siftgeo_read is not implemented\');
  end

 case '.fvecs'
%  assert (nargout == 1);
  if verbose, fprintf ('< load fvecs file %s\n', filename); end
  if nmax == Inf,   X = fvecs_read (filename);
  elseif nmin == 1, X = fvecs_read (filename, nmax);
  else              X = fvecs_read (filename, bounds);
  end

 case '.ivecs'
%  assert (nargout == 1);
  if verbose, fprintf ('< load ivecs file %s\n', filename); end
  if nmax == Inf,      X = ivecs_read (filename);
  elseif nmin == 1,    X = ivecs_read (filename, nmax);
  else                 X = ivecs_read (filename, bounds);
  end

 case {'.uint8','.uchar'}
  assert (nargout == 1);
  if nargin < 2, nrows = 1; end
  if verbose, fprintf ('< load uint8 file %s\n', filename); end

  fid = fopen (filename, 'rb');
  fseek (fid, (nmin-1) * nrows, 'bof');
  X = fread (fid, [nrows,nmax], 'uint8=>uint8');
  fclose (fid);

  case {'.int','.int32'}
  assert (nargout == 1);
  if nargin < 2, nrows = 1; end
  if verbose, fprintf ('< load int file %s\n', filename); end

  fid = fopen (filename, 'rb');
  fseek (fid, 4 * (nmin-1) * nrows, 'bof');
  X = fread (fid, [nrows,nmax], 'int32=>int32');
  fclose (fid);

  case {'.uint','.uint32'}
  assert (nargout == 1);
  if nargin < 2, nrows = 1; end
  if verbose, fprintf ('< load int file %s\n', filename); end

  fid = fopen (filename, 'rb');
  fseek (fid, 4 * (nmin-1) * nrows, 'bof');
  X = fread (fid, [nrows,nmax], 'uint32=>uint32');
  fclose (fid);

 case {'.float','.f32','.float32','.single'}
  assert (nargout == 1);
  if nargin < 2, nrows = 1; end
  if verbose, fprintf ('< load raw float32 file %s\n', filename); end

  fid = fopen (filename, 'rb');
  fseek (fid, 4 * (nmin-1) * nrows, 'bof');
  X = fread (fid, [nrows,nmax], 'real*4=>single');
  fclose (fid);

 otherwise
  error ('Unknown extension: %s', ext);

end
