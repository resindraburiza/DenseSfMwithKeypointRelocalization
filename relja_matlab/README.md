# relja_matlab

> Version 1.02 (29 Feb 2016)

This library contains miscellaneous utilities written by Relja Arandjelović. It is used extensively in the [NetVLAD](https://github.com/Relja/netvlad) library.

The library is distributed under the BSD License (see the `LICENCE` file).

File

    matconvnet/relja_simplenn_move.m

is taken from the excellent [MatConvNet](http://www.vlfeat.org/matconvnet/) library, written by Andrea Vedaldi and Karel Lenc, and modified by Relja Arandjelović for some added functionality.

## Dependencies

The functions related to MatConvNet (i.e. in folder `matconvnet`) clearly depend on:

1. [MatConvNet](http://www.vlfeat.org/matconvnet/) (requires v1.0-beta18 or above)

2. Optional but **highly** recommended for speed if you want to use the `relja_retrievalMAP` function (it computes the mAP for retrieval; to not use this dependency, uncomment the relevant lines in the `relja_retrievalMAP.m` file): [Yael_matlab](http://yael.gforge.inria.fr/index.html) (tested using version 438)
    - To download it's easiest to go [here](http://yael.gforge.inria.fr/index.html) and download the precompiled yael_matlab binaries for your OS (e.g. [yael_matlab_linux64_v438.tar.gz](https://gforge.inria.fr/frs/download.php/file/34218/yael_matlab_linux64_v438.tar.gz))


# Changes

- **1.02** (29 Feb 2016)
    - Adapts the code to account for major changes in matconvnet-1.0-beta17's SimpleNN
    - Removed the redundant `relja_simplenn` since `vl_simplenn` has sufficient functionality now (from matconvnet-1.0-beta18)

- **1.01** (29 Feb 2016)
    - Added a few more functions needed for NetVLAD v1.01 (e.g. mAP computation)

- **1.00** (04 Dec 2015)
    - Initial public release
