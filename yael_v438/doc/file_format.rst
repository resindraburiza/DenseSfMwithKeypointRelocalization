
File exchange format
====================

Yael uses a simple file format to store byte, integer or floating
point vectors. Each vector is stored by

* writing its length ``d`` as an integer (4 bytes, little-endian)

* writing its ``d`` components in binary format. 

Until now, we have used only single-precision floating point
numbers. Therefore the size of storing an integer or a floating-point
vector is simply ``sizeof(int) + 4 * d`` :math:` = 4 (d+1)`, as both
the dimension and the components require 4 bytes each. For byte
vectors, it is similarly equal to ``4+d``.

By convention we will call a file containing several vectors of the
same kind 'fvecfile', 'ivecfile' and 'bvecfile'.

Matrices are stored as a concatenation of vectors, again without a
header. A float matrix is therefore a fvecfile where all vectors are
the same length. Its suggested filename extention is ``.fvecs``.

Some particular high-level functions are defined for these files. 

Remarks:

* Since there use no header, several files of same type can be
  concatenated using regular the ``cat`` Unix command to produce a
  file containing the concatenation of the vector.

* in the ``progs`` subdirectory, the utilities ``xvecfile`` 
  (x= ``f``, ``i`` or ``b``) receive a xvecfile on standard input 
  and produce a text output. Usage::

    cat myfile.fvecs | fvecfile

  or, equivalently::

    fvecfile < myfile.fvecs


* The Yael functions used to read these the files in C, Python and 
  Matlab are called ``Xvecs_read`` (x= ``f``, ``i`` or ``b``). The
  prototype of the function depends on whether you call it from C,
  Python or Matlab. See the I/O interface in vector.h. 

