%  sw= relja_startsWith(bigString, smallString)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function sw= relja_startsWith(bigString, smallString)
    sw= strncmp(bigString, smallString, length(smallString));
end
