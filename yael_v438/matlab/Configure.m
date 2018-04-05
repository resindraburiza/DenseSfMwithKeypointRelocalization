% Compilation parameters
openmp = true;   % De-activated by default since latest MacOS needs hacking to have it working
sse4 = true;
arpack = true;

% Set flags 
cflags = '-I.. -Wall -O3 ';
ldflags = '';

if openmp
  cflags = ['-fopenmp ' cflags ];
  ldflags = ['-fopenmp ' ldflags];
end

if sse4
  cflags = ['-msse4 ' cflags ];
end

if arpack
  cflags = [cflags ' -DHAVE_ARPACK '];
  ldflags = [ldflags ];
end

  
fprintf ('cflags = %s\n', cflags);
fprintf ('ldflags = %s\n', ldflags);



list = ...
 {'yael_kmeans.c ../yael/kmeans.c ../yael/vector.c ../yael/machinedeps.c ../yael/binheap.c ../yael/nn.c ../yael/sorting.c', ...
  'yael_gmm.c ../yael/gmm.c ../yael/kmeans.c ../yael/vector.c ../yael/matrix.c ../yael/eigs.c ../yael/machinedeps.c ../yael/binheap.c ../yael/nn.c ../yael/sorting.c', ...
  'yael_fisher.c ../yael/gmm.c ../yael/kmeans.c ../yael/vector.c ../yael/matrix.c ../yael/eigs.c ../yael/machinedeps.c ../yael/binheap.c ../yael/nn.c ../yael/sorting.c', ...
  'yael_fisher_elem.c ../yael/gmm.c ../yael/kmeans.c ../yael/vector.c ../yael/matrix.c ../yael/eigs.c ../yael/machinedeps.c ../yael/binheap.c ../yael/nn.c ../yael/sorting.c', ...
  'yael_nn.c ../yael/vector.c ../yael/machinedeps.c ../yael/binheap.c ../yael/nn.c ../yael/sorting.c', ...
  'yael_kmax.c ../yael/vector.c ../yael/machinedeps.c ../yael/binheap.c ../yael/sorting.c', ...
  'yael_kmin.c ../yael/vector.c ../yael/machinedeps.c ../yael/binheap.c ../yael/sorting.c', ...
  'yael_L2sqr.c ../yael/binheap.c ../yael/nn.c ../yael/vector.c  ../yael/machinedeps.c ../yael/sorting.c', ...
  'yael_cross_distances.c ../yael/binheap.c ../yael/nn.c ../yael/vector.c  ../yael/machinedeps.c ../yael/sorting.c', ...
  'yael_hamming.c ../yael/hamming.c ../yael/machinedeps.c ', ...
  'yael_ivf.c ../yael/ivf.c ../yael/hamming.c'};


if arpack
   list = [list, ...
   'yael_eigs.c ../yael/eigs.c ../yael/vector.c ../yael/matrix.c ../yael/machinedeps.c ../yael/sorting.c ../yael/binheap.c', ...
   'yael_svds.c ../yael/eigs.c ../yael/vector.c ../yael/matrix.c ../yael/machinedeps.c ../yael/sorting.c ../yael/binheap.c'];
end

cmd = 'mex -g -largeArrayDims -DFINTEGER=long -lmwblas -lmwlapack CFLAGS="\\$CFLAGS %s" LDFLAGS="\\$LDFLAGS %s" -lmwarpack %s ;\n'

% Open a file for writing
fid = fopen ('Make.m', 'w');

fprintf (fid, 'mex siftgeo_read.c ;\n');
for a = list 
  fprintf (fid, cmd, cflags, ldflags, a{1});
end

fclose (fid);
  

delete *.o


