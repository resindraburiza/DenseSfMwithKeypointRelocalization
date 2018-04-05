/*
Copyright © INRIA 2009-2014.
Authors: Matthijs Douze & Herve Jegou
Contact: matthijs.douze@inria.fr  herve.jegou@inria.fr

This file is part of Yael.

    Yael is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Yael is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Yael.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "mex.h"
#include <yael/sorting.h>

void mexFunction (int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray*prhs[])

{
  if (nrhs != 2) 
    mexErrMsgTxt ("Invalid number of input arguments");
  
  if (nlhs > 2)
    mexErrMsgTxt ("1 o 2 output arguments are required");

  if (mxGetClassID(prhs[0]) != mxSINGLE_CLASS)
    mexErrMsgTxt ("First parameter must be a single precision matrix"); 


  int d = mxGetM (prhs[0]);
  int n = mxGetN (prhs[0]);
  int k = mxGetScalar (prhs[1]);
  int tr = 0;   /* transpose or not in case of only one vector */

  if (mxGetClassID(prhs[0]) != mxSINGLE_CLASS)
    mexErrMsgTxt ("need single precision array"); 
  float * v = (float*) mxGetPr (prhs[0]);


  if (d == 1 && n > 1) {
    d = n;
    n = 1;
    tr = 1;
  }

  if (k > d)
    mexErrMsgTxt ("k should be smaller than the number of vectors"); 

  if (tr == 0) {
    plhs[0] = mxCreateNumericMatrix (k, n, mxSINGLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericMatrix (k, n, mxINT32_CLASS, mxREAL);
  }
  else {
    plhs[0] = mxCreateNumericMatrix (1, k, mxSINGLE_CLASS, mxREAL);
    plhs[1] = mxCreateNumericMatrix (1, k, mxINT32_CLASS, mxREAL);
  }

  float * val = (float*) mxGetPr (plhs[0]);
  int * idx = (int*) mxGetPr (plhs[1]);

  int i, j;
  for (j = 0 ; j < n ; j++) {
    fvec_k_min (v, d, idx, k);
    for (i = 0 ; i < k ; i++) {
      val[i] = v[idx[i]];
      idx[i]++; /* idx start from 1 in matlab */
    }
    idx += k;
    val += k;
    v += d;
  }
} 
