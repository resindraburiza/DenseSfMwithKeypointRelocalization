Matlab
======

.. highlight:: matlab

This chapter is dedicated to the Matlab interface. However, most of the
comments here have their Octave equivalent.

Content of the Matlab interface
-------------------------------

The Matlab interface of Yael is limited to functions that are not
available in Matlab, i.e., the most basic matrix manipulation functions are
readily available in Matlab or can be implemented trivially.

The functions currently provided are:

* ``yael_kmeans``. Although there is a kmeans function in Matlab, that
  one is not very efficient. Moreover, it is not available in the core
  Matlab program, since it requires a specific toolbox.

* ``yael_knn`` is used to find the :math:`k` nearest neighbors with respect to
  the Euclidean distance. Although for :math:`k=1` Matlab does a good job,
  finding :math:`k>1` neighbors requires the ``sort`` function,
  which is very inefficient when :math:`k` is small compared to the number
  of vectors.

* ``yael_hamming`` is used to compute the Hamming distances between binary vectors
  represented in a compact form. The function also allows one to get only the Hamming 
  distances below a threshold (range search). 

* ``yael_L2sqr`` computes all the square distances between two sets of
  vectors. Therefore, it computes :math:`n_1\times n_2` distances.

* ``yael_kmin`` and ``yael_kmax`` compute the :math:`k` smallest (or
  largest) values of a set of scalar. It is more efficient than sorting
  the data.

* ``yael_vecs_normalize`` normalizes a set of vectors. 

* ``yael_gmm`` learns a Gaussian mixture model (diagonal form).

* ``yael_fisher`` computes the Fisher Kernel representation of a set
  of features.

* ``yael_ivf`` is used for creating an inverted file system. 



Using the Yael interface
------------------------

The functions are implemented by Mex-file, which requires to compile
the Matlab interface of Yael (disabled by default). To do so, just
type ``make`` in the ``matlab`` directory. You might obtain a warning
about a version with the gcc version used. We never observed any
trouble related to that point. In order for the functions to be found
in matlab, you should include this subdirectory in the MATLAB path,
for instance by setting the environment variable::

  export MATLABPATH=$MATLABPATH:YAELROOT/matlab

in your shell configuration files (e.g., ``~/.bash_profile`` for bash)
where ``YAELROOT`` should be set to fit your local
configuration. Inside Matlab, the ``addpath`` function can be used for
the same purpose.

Alternately, you can compile directly from Matlab by executing the ``Make.m`` 
m-file. Just ensure that you are in the correct directory before launching
this command. 

Conveniently, Matlab and Yael use the same convention for matrix
storage (column-major).

All the functions of the Yael-Matlab interface use single precision
vectors, i.e., the Matlab equivalent of float. This is in contrast to
Matlab's default double precision floating numbers. Therefore, one has
to cast the input data to single precision when calling Yael
functions, e.g., as::

  [dis, ids] = yael_nn(single(v), single(q), 10)
