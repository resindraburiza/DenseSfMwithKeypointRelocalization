%  perf= relja_randomHex(n)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function s= relja_randomHex(n)
    s= randsample(['a':'f', '0':'9'], n, true);
end
