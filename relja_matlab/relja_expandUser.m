%  res= relja_expandUser( fn )
%
%  Author: Relja Arandjelovic (relja@relja.info)

function fn= relja_expandUser( fn )
    if strncmp(fn, '~', 1)
        fn= [getenv('HOME'), fn(2:end)];
    end
end
