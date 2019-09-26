%  fns= relja_dir(dirname)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function fns= relja_dir(dirname)
    fns= dir(dirname);
    fns= sort({fns.name}');
    if( length(fns)>=2 && strcmp(fns(1), '.') && strcmp(fns(2), '..') )
        fns= fns(3:end);
    end
end
