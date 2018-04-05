Hamming distances
-----------------

Yael provides very *efficient* functions to compute Hamming distances between
binary vectors. Hereafter, we show how to use them in Matlab.
The same functionalities are (of course) available from the C and python interface.

To make the following test, that the subdirectory 'matlab' of yael
is in the Matlab path. If no, you can add it with the command ``addpath``.
Please also ensure that the mex-file ``yael_hamming.c`` is  compiled,
otherwise this test program invokes the non-optimized version implemented
in ``yael_hamming.m``, which is super-slow.


The Hamming functions operates on compact bit-vectors. A bit-vector is stored
as an ``uint8`` vector, therefore each entry of the Matlab vector stores
effectively 8 bits.
In the following lines, we randomly generate bitvectors for the sake of exposure.

.. code-block:: matlab

  nbits = 64;            % size of the bit vector, in bits
  d = nbits / 8;         % corresponding size in terms of Matlab uint8 length
  na = 100000;
  nb = 1000;

  % Generate some random bit vectors uniformely
  a = uint8 (randi (256, d, na) - 1);
  b = uint8 (randi (256, d, nb) - 1);

We display the first 8 vectors of `a`:

.. code-block:: matlab

  >> a(:,1:10)

  ans =

    240  166  230  182  164  138   40  170  113   94
     23  200  238  162  144   43   98  115  195  206
     35  115   41  235  148  139   40   63   94   80
    202  134  251  168  210  250   59   71  101   76
     76  183  245  199    1   81  216   60   17   90
     45   64   86   24  182  160   27  127  242  233
    176  249  106   60  205   61   15  166  184  159
    133  242  243  109  106   19  165  149   98  242


Now, we can compute the pairwise distances between `a` and `b`.

.. code-block:: matlab

  ht = 16;
  tic
  dis = yael_hamming (a, b) ;
  fprintf ('%dx%d = %d Hamming distances computed in %.3fs\n', na, nb, na*nb, toc);
  disp (dis(1:8,1:6));

This typically produces the following output:

.. code-block:: matlab

    100000x1000 = 100000000 Hamming distances computed in 0.161s
       37     31     32     30     30     33
       30     30     33     31     31     28
       30     24     35     29     29     30
       30     28     25     29     31     30
       26     36     31     37     31     34
       35     33     28     32     26     35
       31     35     30     28     36     35
       33     27     36     26     30     27

where we observe that 100 million distances are computed in less than 0.2 second,
at least on my laptop. Now, let detect the distances below a threshold `ht`.
his can be done  with the standard Matlab function ``find``.

.. code-block:: matlab

  tic;
  [idxa, idxb] = find(dis < ht);
  fprintf ('Found %d distances below %d in %.3fs\n', numel (idxa), ht, toc);

with following output:

.. code-block:: matlab

    Found 1285 distances below 16 in 0.502s

Overall, finding these pairs takes 0.66s, the dominant cost being the one of
the matlab function ``find``! Additionally, Storying this matrix (of type ``uint16``)
is memory costly (200Mbytes)

.. code-block:: matlab

  >> whos dis
    Name           Size                  Bytes  Class     Attributes

    dis       100000x1000            200000000  uint16


Instead, what we can do is to directly retrieve the pairs of vectors in `a`
and `b` whose distances are below ht. This is done as follows:

.. code-block:: matlab

  tic
  [ids, hdis] = yael_hamming (a, b, ht);
  fprintf ('Found %d distances below %d in %.3fs\n', numel (idxa), ht, toc);

The variable `ids` is a 2*nmatches vector of identifiers (for `a` and `b`),
while `hdis` gives the corresponding distances. The output is:

.. code-block:: matlab

  Found 1285 distances below 16 in 0.185s

This is at least 3 times faster. Most importantly, the function never allocates
a big matrix. It is therefore possible to compute much more distances, as
shown in the example below (only on a machine with enough RAM and good cache size):

.. code-block:: matlab

  na = 100000;
  nb = 100000;
  nbits = 64;
  d = nbits / 8;
  ht = 16;

  a = uint8 (randi (256, d, na) - 1);
  b = uint8 (randi (256, d, nb) - 1);

  tic
  [ids, hdis] = yael_hamming (a, b, ht);
  toc

On my machine, this takes 18.12 seconds to compute these 100,000^2= 10 billion distances!
Observe that the complexity is linear in `na` and `nb`.
