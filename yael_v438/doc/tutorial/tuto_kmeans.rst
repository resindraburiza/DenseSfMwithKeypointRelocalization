A simple example: k-means
-------------------------

C version
+++++++++

Yael was originally designed as a lightweihgt library for vector
manipulation in C. Functions in ``yael/vector.h`` do exactly
that. They are seldom useful when used from numerical languages like
Numpy or Matlab.

The following example peforms a k-means clustering on a set of random
vectors.

.. code-block:: c

  #include <stdio.h>

  #include <yael/vector.h>
  #include <yael/kmeans.h>
  #include <yael/machinedeps.h>

  int main (int argc, char ** argv)
  {
    int k = 50;                           /* number of cluster to create */
    int d = 20;                           /* dimensionality of the vectors */
    int n = 1000;                         /* number of vectors */
    int nt = 2;                           /* number of threads to use */
    int niter = 0;                        /* number of iterations (0 for convergence)*/
    int redo = 1;                         /* number of redo */

    float * v = fvec_new_rand (d * n);    /* random set of vectors */

    /* variables are allocated externaly */
    float * centroids = fvec_new (d * k); /* output: centroids */
    float * dis = fvec_new (n);           /* point-to-cluster distance */
    int * assign = ivec_new (n);          /* quantization index of each point */
    int * nassign = ivec_new (k);         /* output: number of vectors assigned to each centroid */

    double t1 = getmillisecs();
    kmeans (d, n, k, niter, v, 1, 1, redo, centroids, dis, assign, nassign);
    double t2 = getmillisecs();

    printf ("kmeans performed in %.3fs\n", (t2 - t1)  / 1000);

    ivec_print (nassign, k);

    free(v); free(centroids); free(dis); free(assign); free(nassign);

    return 0;
  }

This code can be compiled with::

  gcc test_kmeans.c -I my_yael_dir -L my_yael_dir/yael/ -lyael

where ``my_yael_dir`` is the directory where Yael was compiled. Since
there is no separate install stage, the shared library and include files are
in a single directory (``my_yael_dir/yael``). It should run in less than 100 ms.

By convention, the includes are relative to the install directory,
so they always have a ``yael/`` prefix.

``kmeans`` is an important Yael function. It has several variants that
return only part of the information, eg. only the centroid table. When
there are different variants, the primitive one returns vector and
matrix results in arrays allocated by the caller.




Python version
++++++++++++++

The equivalent call to kmeans is

.. code-block:: python

  import numpy as np
  from yael import ynumpy
  import time

  k = 50                           # number of cluster to create
  d = 20                           # dimensionality of the vectors
  n = 1000                         # number of vectors
  nt = 2                           # number of threads to use
  niter = 0                        # number of iterations (0 for convergence)
  redo = 1                         # number of redo

  v = np.random.rand(n, d)         # line vectors in Numpy!
  v = v.astype('float32')          # yael likes floats better than doubles

  t0 = time.time()

  (centroids, qerr, dis, assign, nassign) = \
        ynumpy.kmeans(v, k, nt = nt, niter = niter, redo = redo, output = 'full')

  t1 = time.time()

  print "kmeans performed in %.3f s" % (t1 - t0)

  print nassign

To run this, the PYTHONPATH should point to ``my_yael_dir``. Since the
import statement is ``from yael import ...`` Python will know it has to
look in the subdirectory ``yael``.

The kmeans call is very similar to the C version. Only the arguments
``v`` and ``k`` are mandatory. For the other ones, it will use
reasonable defaults.

Matlab version
++++++++++++++

.. code-block:: matlab

  % The subdirectory 'matlab' of yael should be in the Matlab path
  % This can be done with the command addpath('MY_YAEL_MATLAB_PATH')

  k = 50;                    % number of cluster to create
  d = 20;                    % dimensionality of the vectors
  n = 1000;                  % number of vectors
  v = single(rand (d, n));   % random set of vectors
  niter = 0;                 % typically use no more than 50 in practice
  redo = 1;                  % number of redo
  seed = 3;                  % 0: no seeding, values > 0 are used as seed

  tic
  % Only the two first arguments are mandatory
  [centroids, dis, assign, nassign] = yael_kmeans (v, k, 'niter', niter, 'redo', 1, 'seed', seed);
  toc
