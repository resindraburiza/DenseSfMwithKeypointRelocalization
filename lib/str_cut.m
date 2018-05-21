%str_cut Cut off last piece according to a delimeter from a string.
%
%   [ head, tail ] = str_cut(s, delim)

function [ head, tail ] = str_cut(s, delim)

if nargin < 2, delim = '/'; end

if delim == '/' % on Windows, use '\' instead of '/'
  norm = findstr(s,'/');
  back = findstr(s,'\');
  if ~isempty(back)
    if isempty(norm)  |  (~isempty(norm)  &  max(back) > max(norm))
      delim = '\';
    end
  end
end

idcs = findstr(s,delim);
if isempty(idcs),
  head = s; 
  tail = [];
else
  head = s(1:idcs(end)-1);
  tail = s(length([head delim])+1:end);
end
