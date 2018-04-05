C interface
===========

.. highlight:: c

The C API is object-oriented whenever applicable, with constructors
and destructors for each structure.

The include directory should be set to the \yroot directory, so that a
yael file is included using the prefix ``yael/``. For instance,
including the primitive for vectors is performed by::

  #include <yael/vector.h>

The documentation of the functions and data structures is in the
header files. It can be extracted and formatted by ``doxygen``, run by
invoking ``make`` in the ``doc`` subdirectory.

The best thing to do to have an operational Makefile and program is
probably to look at the test files included in the ``YAELROOT/test/``
subdirectory.



Conventions
-----------

Vectors are represented as C arrays of basic elements. Functions
operating on them are prefixed with:

* ``ivec``: basic type is ``int``

* ``fvec``: basic type is ``float``

* ``dvec``: basic type is ``double``

* ``bvec``: basic type is ``unsigned char``

Most of the functions are associated with ``ivec``  and ``fvec`` types. 
Vector sizes are passed explicitly, as long int's to allow for
large arrays on 64 bit machines. Vectors can be free'd with ``free()``

.. code-block:: c

  /* Generate a random array using a thread-safe function */
  long n = 100;	\
  seed = 666;
  float * v = fvec_new_randn_r (n, seed);
  
  double sum_v = fvec_sum (v, n);
  
  /* free the vector */
  free (v);

Arrays of vectors are stored contiguously in memory. 
As shown above, an array of n float vectors of dimension d is simply declared 
a pointer on float, as ``float *fv``. 

The `i`-th element of vector `j` of vector array `vf`, where :math:`0
\le i < d` and :math:`0 \le j < n` is::

   vf[j * d + i]

It can also be seen as a column-major matrix of size :math:`d * n`:.

Since the library is intended to be fast, 32-bit floating point
numbers are preferred over 64-bit ones almost everywhere.

We acknowledge the influence of Fortran conventions in this design.

Multi-threading in Yael
------------------------

In order to exploit multi-CPU and multi-core architectures, many
functions in Yael execute in multiple threads. They take an additional
parameter (``int nt``) that defines the number of threads to use.

The number of CPUs available on the machine is given by the
``count_cpu()`` function.


Multi-threading primitive
~~~~~~~~~~~~~~~~~~~~~~~~~

Most multi-threading operations in Yael are implemented via the function::

  void compute_tasks (int n, int nt,
                      void (*task_fun) (void *arg, int tid, int i),
                      void *task_arg);

The function executes `n` tasks on `nthread` threads. For each task,
the callback `task_fun` is called with ``task_arg`` as first argument,
``i = 0..n-1`` set to the task number, and ``tid = 0..nt-1`` set to
the thread number.

Some operations are also multi-threaded via OpenMP pragmas. These are
enabled only with the ``--enable-openmp`` option of the
``./configure.sh`` script, else they will run single-threaded.


Best practices
~~~~~~~~~~~~~~

It is often advisable to perform multi-threading at the highest level
possible. For example, with two nested loops::

  for (i = 0 ; i < 1000 ; i++)    
    for (j = 0 ; j < 1000 ; j++) 
      expensive_operation (i, j);


It is more efficient (and often easier) to define a task as one outer
loop. This reduces the number of synchronization barriers.


Multithreading and random numbers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Yael relies on the random number generators ``rand()`` and
``lrand48()``. These can be seeded, which changes a global state
variable. However, if the random number generators are called from
multiple threads, the sequences get mixed and are not reproducible any
more.

To avoid this, several Yael functions that use random generators have
an additional parameter that sets a local random seed. They are often
suffixed with ``_r`` (**r**\ eentrant), for example:
``fvec_new_rand_r``, ``ivec_new_random_idx_r``, ``kmeans``.

 
