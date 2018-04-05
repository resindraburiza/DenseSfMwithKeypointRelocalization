% Test program for Hamming distance computation
% The mex-file yael_hamming.c should be compiled, otherwise this test program
% invokes the yael_hamming.m function, which is super-slow

nbits = 64;
d = nbits / 8;
na = 8;
nb = 10;
ht = nbits; %nbits / 2 - 1;

% Generate some random bit vectors uniformely
a = uint8 (randi (256, d, na) - 1);
b = uint8 (randi (256, d, nb) - 1);

dis = yael_hamming (a, b) ; 
[ids2, hdis2] = find(dis < ht);

[ids, hdis] = yael_hamming (a, b, ht); 

% Check that both version are identical
F = full (sparse (double(ids(1,:)),double(ids(2,:)),double(hdis)))
assert (norm(F-double(dis)) == 0)


% Now, something serious
nbits = 64;
d = nbits / 8;
na = 100000;
nb = 1000;
ht = 20;

a = uint8 (randi (256, d, na) - 1);
b = uint8 (randi (256, d, nb) - 1);


tic
dis = yael_hamming (a, b) ; 
[ids2, hdis2] = find(dis < ht); 
toc

tic
[ids, hdis] = yael_hamming (a, b, ht); toc


fprintf ('nb neighbors=%d (avg=%.2f)\nmin distance=%d\n', ...
         numel(ids(:)), numel(ids(:))/nb, min(hdis(:)));
