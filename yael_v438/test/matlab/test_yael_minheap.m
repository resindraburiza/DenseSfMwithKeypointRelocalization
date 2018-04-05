mex yael_minheap.c

nq = 1000;
k = 10;
nb = 1000;

bhv = ones (k, nq, 'single');
bhv (:) = inf;
bhidx = zeros (k, nq, 'uint32');

for i = 1:500
   i
   val = randn (nb, nq, 'single');
   idx = uint32((i-1) * nb + (1:nb)');

   [bhv,bhidx] = yael_minheap (bhv, bhidx, val, idx);

end
