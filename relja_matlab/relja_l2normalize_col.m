%  Y= relja_l2normalize_col( X )
%
%  Author: Relja Arandjelovic (relja@relja.info)

function Y= relja_l2normalize_col( X )
    Y= bsxfun(@rdivide, X, sqrt(sum(X.^2,1)) + 1e-12 );
end
