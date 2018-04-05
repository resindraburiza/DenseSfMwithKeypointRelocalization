Troubleshooting
===============

Before reporting any trouble in installing the library, please ensure
that the following points are correctly configured. 
Most of the problems for the compilation of the core C library should be related to an incorrect configuration
in ``makefile.inc``.


* **Problems when linking**. The environment variable associated with
  dynamic library should be set to ``YAELROOT/yael``.

+--------------+--------------------+------------------------+-------------------------------+
| Architecture | \yael library name | environment variable   | command to check missing libs |
+==============+====================+========================+===============================+
| Linux 32/64  | ``libyael.so``     | ``LD_LIBRARY_PATH``    | ``ldd libyael.so``            |
+--------------+--------------------+------------------------+-------------------------------+
| MacOS X      | ``libyael.dylib``  | ``DYLD_LIBRARY_PATH``  | ``otool -L libyael.dylib``    |
+--------------+--------------------+------------------------+-------------------------------+

  Note that the path to the dynamic library can also be hardcoded in the
  code that used i, with ``-Wl,-rpath,YAELROOT``. This is done for
  Python's interface.

* **Python**. The ``PYTHONPATH`` environment variable should
  point to YAELROOT. The ``*_LIBRARY_PATH`` variable does not need to be set.

* Segfault in Mexfile: MacOS 32/64 bits. If you have a 32 bits Matlab
  version with MacOS, then you should check that you have used the
  flag ``--mac32`` when configuring Yael. 


* In Matlab, some issues come from the regular changes in releases of Matlab. We do our best to find some solutions (because we need this ourselves). 

* On MacOS, the use by default of the LLVM compiler also cause some (solvable) issues to use multi-threading in some of the functions. By default, multi-threading is disabled. Yet it is still available in some functions involving matrix multiplication, such as yael_nn. 

