%  relja_progress(i, n, prefix, progressID)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function relja_progress(i, n, prefix, progressID)
    if nargin<3, prefix= ''; else prefix= [prefix, ' ']; end
    if nargin<4, progressID= tic; end
    if i<5 || rem(i,floor(n/10))==0 || mod(log2(i),1)==0 || i==n
        tElapsed= toc(progressID);
        dateString= datestr(now);
        if i<=1
            relja_display( ...
                '%s%s %d / %d', ...
                prefix, dateString, i, n );
        else
            avgtime= tElapsed/(i-1);
            relja_display( ...
                '%s%s %d / %d; time %s; left %s; avg %.4f s', ...
                prefix, dateString, i, n, ...
                relja_hrminsec(tElapsed), ...
                relja_hrminsec( avgtime*n-tElapsed), ...
                avgtime );
        end
    end
end
