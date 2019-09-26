%  ret= relja_endsWith(s, se)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function ret= relja_endswith(s, se)
    ret= length(s)>=length(se) && ...
        strcmp( s( end-length(se) + [1:length(se)] ), se )==1;
end
