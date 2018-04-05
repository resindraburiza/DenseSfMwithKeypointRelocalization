Welcome to Yael's documentation!
================================

.. toctree::
   :maxdepth: 1

   Home              <self>
   Getting started   <gettingstarted>
   C interface       <cinterface>
   python interface  <python_interface>
   Matlab interface  <matlab_interface>
   File format       <file_format>
   Troubleshooting   <troubleshooting>
   License           <license>
   Tutorial          <tutorial>

.. These images will have to be included
  .. image:: figs/logoinria.png
     :height: 100px
  .. image:: figs/logoyael.png
     :height: 100px
     :align: right


Yael
====
Yael is a library implementing computationally intensive functions used in large scale image retrieval, such as neighbor search, clustering and inverted files. The library offers interfaces for C, Python and Matlab.


Introduction
============
This website is a tutorial for first steps with Yael. Most of the remarks and
details here will be just but useless for skilled programmers, as the
structure of the library should be clear enough. The documentation
related to Python should however interest any programmer wanting to
use this interface.

Yael is a library for performing efficient basic operations,
in particular kmeans and exhaustive nearest neighbor search function.
It offers three interfaces:

* C,
* Python,
* Matlab (Octave extension is included, but not fully checked at each release).

The library has been tested under different architectures, in particular

* Linux 32 bits: Fedora Core 11
* Linux 64 bits: Fedora Core 10, Fedora Core 11, Ubuntu Karmic, Debian 4.1.2-25
* Mac OS X.

The library has not been packaged nor tested for Microsoft Windows.
Some people have however adapted some previous version of the library on
this operating system.

The C API is object-oriented in spirit whenever applicable, with
constructors and destructors for each structure. All functions are
re-entrant, but unless otherwise specified, they are not
multi-threaded. Threading is assumed to occur at a higher level.
In particular, the python interface offers a very simple way
to parallelize function calls.
