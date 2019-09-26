%  [U, lams, mu, Utmu]= relja_PCA(x, nPCs, subtractMean)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function [U, lams, mu, Utmu]= relja_PCA(x, nPCs, subtractMean)
    % assumes x= ndims x nvectors
    % automatically decides if primal or dual should be used
    
    if nargin<3, subtractMean= true; end
    
    nPoints= size(x,2);
    nDims= size(x,1);
    if nargin<2, nPCs= nDims; end
    
    if subtractMean
        mu= mean(x,2);
        x= x - repmat(mu,1,size(x,2));
    else
        mu= zeros([size(x,1),1], class(x));
    end
    
    if nDims<=nPoints
        doDual= false;
        X2= double(x*x')/(nPoints-1);
    else
        doDual= true;
        X2= double(x'*x)/(nPoints-1);
    end
    
    if nPCs < size(X2,1)
        [U, L]= eigs(X2, nPCs);
    else
        [U, L]= eig(X2);
    end
    lams= diag(L);
    
    % make sure in decreasing size
    [lams, sortInd]= sort(lams,'descend');
    U= U(:,sortInd);
    
    if doDual
        U= x * ( U * diag(1./sqrt(max(lams,1e-9))) / sqrt(nPoints-1) );
    end
    
    Utmu= U'*mu;
    
end
