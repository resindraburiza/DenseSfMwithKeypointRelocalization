addpath('../../matlab')

d = 2000
nev = 20

a=rand(d, d);

a=a+a'; 

fprintf('ref\n'); 
tic
[vecs_ref, vals_ref ] = eigs(a, nev); 
toc
vals_ref = diag(vals_ref);

fprintf('new\n'); 
tic
[vecs_new, vals_new ] = yael_eigs(single(a), nev); 
toc

value_error = (vals_ref - vals_new) ./ abs(vals_ref)

% sign ambiguity
errs1 = sum(abs(vecs_ref - vecs_new)); 
errs2 = sum(abs(vecs_ref + vecs_new)); 

vector_error = min(errs1, errs2)

