function dirgen(fn)

pathstr = fileparts(fn);
if ~exist(pathstr,'dir')
  mkdir(pathstr);
end;
