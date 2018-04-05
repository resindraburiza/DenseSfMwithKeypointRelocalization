% Generic way to save files depending on the type (determined by extension)
function save_ext (filename, X, verbose)

% Retrieve the extension of the file
ext = regexp (filename, '\.(\w)*$');
if length(ext) == 0
  error ('The filename should have an extension');
end
ext = filename (ext:end);

% Default
Y = [];
if nargin < 3, verbose = true; end;

switch ext
 
 case '.fvecs'
  if verbose, fprintf ('> write fvecs file %s\n', filename); end
  fvecs_write (filename, X);
  
 case '.ivecs'
  if verbose, fprintf ('> write ivecs file %s\n', filename); end
  ivecs_write (filename, X);
  
 case {'.uint8','.uchar'}
  if nargin < 2, nrows = 1; end
  if verbose, fprintf ('> write uint8 file %s\n', filename); end

  fid = fopen (filename, 'wb');
  fwrite (fid, X, 'uint8');
  fclose (fid);
  
 case {'.int','.int32'}
  if nargin < 2, nrows = 1; end
  if verbose, fprintf ('> write int file %s\n', filename); end

  fid = fopen (filename, 'wb');
  fwrite (fid, X, 'int32');
  fclose (fid);

 case {'.uint','.uint32'}
  if nargin < 2, nrows = 1; end
  if verbose, fprintf ('> write int file %s\n', filename); end

  fid = fopen (filename, 'wb');
  fwrite (fid, X, 'uint32');
  fclose (fid);
  
 case {'.float','.f32','.float32','.single'}
  if nargin < 2, nrows = 1; end
  if verbose, fprintf ('> write raw float32 file %s\n', filename); end
  
  fid = fopen (filename, 'wb');
  fwrite (fid, X, 'single');
  fclose (fid);

 otherwise
  error ('Unknown extension: %s', ext);

end
