Python interface
================

The whole C API is exposed in Python using SWIG, hence the \tc{.swg}
files in the subdirectories. This allows to call C functions from
Python more or less transparently.

Loading and using Yael
-----------------------

Assuming that the ``PYTHONPATH`` environment variable is set to Yael's
installation root, importing the Yael interface and creating a new
vector is done as::

  from yael import yael
  a = yael.fvec_new_0(5)


In order to shorten the call, one could also import the function 
in the current namespace, as::

  from yael.yael import *
  a = fvec_new_0(5)

However, we do not advise to do so, in order to avoid function name
conflicts when using other python libraries jointly with Yael.

Guidelines for the wrapping process
-----------------------------------

* for most of the objects, memory is **not** managed by Python. They
  must be free'd explicitly. The main exception is for vectors, which
  can be explicitly acquired by Python so that they are
  garbage-collected like a Python object

* arrays for simple types are called ``ivec``, ``fvec``, etc. Usage:

  * ``a = ivec(4)`` constructs an array of 4 ints, accessible in Python 
    with ``a[2]``, as one would expect. There is no bound checking:
    the Python object does not know about the size of the array (like
    with C pointers).

  * ``a.cast()`` returns an ``int*`` usable as a C function argument
    (most of the time, the cast is automatic, and ``a`` can be used
    when a function expects an ``int *``).

  * if a C function returns an ``int*``, ``b = ivec.frompointer(x)``
    makes the Python ``a[i]`` valid to access C's ``x[i]``.

  * ``b.plus(2)`` returns ``x + 2`` (pointer arithmetic).

  * ``b = ivec.acquirepointer(x)`` will, in addition, call ``free(x)``
    when the Python object ``b`` is deleted. This function therefore
    ensures that ``x`` will be cleaned up by the Python garbage collector. 
    Often, when a C function returns a newly allocated pointer ``x``,
    it is advisable to immediately do ``x=ivec.acquirepointer(x)``.

  * ``a.clear(3)`` clears out the 3 first elements of the vector.

  * if ``c`` is another ``int*``, ``a.copyfrom(c, 1, 2)`` will copy 2
    elements from ``c`` to ``a`` at offset 1 (ie. ``a[1] = c[0]`` and
    ``a[2] = c[1]``).

  * ``a.tostring(3)`` returns a Python string with the 3 first
    elements of ``a`` as raw binary data. They can be used eg. in the
    ``array`` module.

  * similarly, ``a.fromstring(s)`` fills the first elements of ``a``
    with raw values read from the string.

* all wrapped functions release Python's Global Interpreter Lock (to
  allow multithreaded execution), so Python API functions should not 
  be called in C code.

* output arguments in the C code (their names end in ``_out``) are
  combined with the function results tuples.

NumPy interface
---------------

If Yael is configured with ``--enable-numpy``, arrays can be exchanged
with Numpy arrays. This is done through a series of functions with
self-explanatory names::

  fvec_to_numpy 
  ivec_to_numpy 
  numpy_to_fvec 
  numpy_to_ivec 

Arrays corresponding to Yael's ``fvec`` are of Numpy's
``dtype='float32'``. Moving from yael to numpy produces line vectors,
that can be reshaped to matrices if needed.

These functions copy their arguments. To share the same data buffer
between Yael and Numpy, suffix the function with ``_ref``.

See the ``test_numpy.py`` program for an example usage. 

Numpy interface (high level)
----------------------------

A few functions of Yael are also made available with pure Numpy
arguments and return types. They are in the ``ynumpy`` module. They
include::

  knn
  kmeans
  fvecs_read ivecs_read siftgeo_read

All matrix arguments should be in C indexing, because numpy's support
for Fortran-style indexing is close to unusable. Therefore, in the
function documentation, all references to "columns" should become
"lines". See ``test_ynumpy.py`` for an example.



ctypes interface
----------------

Arrays can also be exchanged with ctypes. This is done by converting
pointers to integers. See ``test_ctypes.py`` for an example.




