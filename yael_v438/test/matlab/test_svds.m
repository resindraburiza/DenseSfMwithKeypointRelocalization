addpath('../../matlab')

d = 100
n = 200
nev = 20

a=rand(d, n);


fprintf('ref\n'); 
tic
[u_ref, s_ref, v_ref ] = svd(a); 
toc
s_ref = diag(s_ref);

fprintf('new\n'); 
tic
[u_new, s_new, v_new ] = yael_svds(single(a), nev); 
toc

s_error = (s_ref(1:nev) - s_new) ./ abs(s_ref(1:nev)); 

s_error = s_error'

% sign ambiguity
u_error_1 = sum(abs(u_ref(:,1:nev) - u_new)); 
u_error_2 = sum(abs(u_ref(:,1:nev) + u_new)); 

u_error = min(u_error_1, u_error_2)

% sign ambiguity
v_error_1 = sum(abs(v_ref(:,1:nev) - v_new)); 
v_error_2 = sum(abs(v_ref(:,1:nev) + v_new)); 

v_error = min(v_error_1, v_error_2)


if 0
% test partial calls
 s_nn           = yael_svds (single(a), nev);
err_p1 = norm(s_new - s_nn) 

[u_nn, s_nn]    = yael_svds (single(a), nev);
err_p2 = norm(s_new - s_nn)  + sum(min(sum(abs(u_new - u_nn)), sum(abs(u_new + u_nn))))

[s_nn, v_nn]    = yael_svds (single(a), nev, 'v');
err_p3 =  norm(s_new - s_nn)  + sum(min(sum(abs(v_new - v_nn)), sum(abs(v_new + v_nn))))

end