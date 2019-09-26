%  res= relja_hrminsec(seconds)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function res= relja_hrminsec(seconds)
    hr= max( 0.0, floor(seconds/60/60) );
    minu= max( 0.0, floor(seconds/60 - hr*60) );
    sec= max( 0.0, floor(seconds - hr*60*60 - minu*60) );
    res= sprintf('%.2d:%.2d:%.2d', hr, minu, sec);
    if nargout<1
        relja_display(res);
    end
end
