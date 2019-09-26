%  [mAP, APs]= relja_retrievalMAP(db, searcher, verbose, kTop)
%
%  Author: Relja Arandjelovic (relja@relja.info)

function [mAP, APs]= relja_retrievalMAP(db, searcher, verbose, kTop)
    if nargin<3, verbose= true; end
    if nargin<4, kTop= 10000; end
    
    kTop= min(db.numImages, kTop);
    
    APs= zeros(db.numQueries, 1);
    
    prog= tic;
    
    for iQuery= 1:db.numQueries
        if verbose
            relja_progress(iQuery, db.numQueries, ...
                sprintf('%.4f', mean(APs(1:(iQuery-1)))), ...
                prog);
        end
        
        if isa(searcher, 'function_handle')
            ids= searcher(iQuery);
        else
            % this is likely to be faster:
            [ids, ~]= yael_nn(searcher.db, searcher.qs(:,iQuery), size(searcher.db, 2));
            % if you don't have yael_nn, do this:
            % distsSq= sum( bsxfun(@minus, searcher.qs(:, iQuery), searcher.db).^2, 1 );
            % [~, ids]= sort(distsSq); ids= ids';
        end
        
        isIgnore= ismember(ids, db.ignoreIDs{iQuery});
        ids= ids(~isIgnore);
        isPos= ismember(ids', db.posIDs{iQuery});
        prec= cumsum(isPos)./[1:length(ids)];
        recall= cumsum(isPos)/length(db.posIDs{iQuery});
        APs(iQuery)= diff([0, recall]) * ( [1, prec(1:(end-1))]+prec )' /2;
    end
    mAP= mean(APs);
    relja_display( '%.4f', mAP );
end
