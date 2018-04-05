function [featreloc] = relocalize_coarse2fine(feat1,cnnlayer)
vec1 = 0:1:1;
[p,q] = meshgrid(vec1, vec1);
pairs = [p(:) q(:)];
featreloc = feat1;
% Lmask = zeros(size(cnnlayer{end}));

for iii=1:length(cnnlayer)
    thissteplayer = cnnlayer{iii};
    for i=1:size(feat1,2)
        f11 = featreloc(2,i);
        f12 = featreloc(1,i);
        k = f11*(2^1)-(2^1-1);
        l = f12*(2^1)-(2^1-1);
        findmax = zeros(1,size(pairs,1));
        for ii=1:size(pairs,1)
            kk = k+pairs(ii,1);
            ll = l+pairs(ii,2);
            if kk > size(thissteplayer,1)
                kk = k;
            end
            if ll > size(thissteplayer,2)
                ll = l;
            end
            findmax(ii) = thissteplayer(kk,ll);
        end
        [~,idx] = max(findmax);
        featreloc(2,i) = k+pairs(idx,1);
        featreloc(1,i) = l+pairs(idx,2);
    end
end
end