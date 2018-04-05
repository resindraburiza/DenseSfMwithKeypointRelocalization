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

#include <stdio.h>
#include <string.h>


#include <assert.h>
#include <math.h>
#include <sys/time.h>

#include <yael/matrix.h>
#include <yael/machinedeps.h>

#include "mex.h"


void mexFunction (int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray*prhs[])

{
  if(!((nrhs == 2 && (nlhs == 1 || nlhs == 2 || nlhs == 3)) || 
       (nrhs == 3 && nlhs == 2))) 
    mexErrMsgTxt("wrong number or inputs or outputs.");
  
  int d = mxGetM (prhs[0]);
  int n = mxGetN (prhs[0]);
  
  if(mxGetClassID(prhs[0]) != mxSINGLE_CLASS)
    mexErrMsgTxt("need single precision array.");

  int nev = (int) mxGetScalar (prhs[1]);


  if(nev > d || nev > n) 
    mexErrMsgTxt("too many singular values requested");
  
  float *u = NULL, *s = NULL, *v = NULL;  

  if(nlhs == 3) {    
    plhs[0] = mxCreateNumericMatrix (d, nev, mxSINGLE_CLASS, mxREAL);
    u = (float*)mxGetPr(plhs[0]);
    plhs[1] = mxCreateNumericMatrix (nev, 1, mxSINGLE_CLASS, mxREAL);
    s = (float*)mxGetPr(plhs[1]);
    plhs[2] = mxCreateNumericMatrix (n, nev, mxSINGLE_CLASS, mxREAL);
    v = (float*)mxGetPr(plhs[2]);
  } else if(nlhs == 2) {
    if(nrhs == 2) {
      plhs[0] = mxCreateNumericMatrix (d, nev, mxSINGLE_CLASS, mxREAL);
      u = (float*)mxGetPr(plhs[0]);
      plhs[1] = mxCreateNumericMatrix (nev, 1, mxSINGLE_CLASS, mxREAL);
      s = (float*)mxGetPr(plhs[1]);
    } else {
      plhs[0] = mxCreateNumericMatrix (nev, 1, mxSINGLE_CLASS, mxREAL);
      s = (float*)mxGetPr(plhs[0]);
      plhs[1] = mxCreateNumericMatrix (n, nev, mxSINGLE_CLASS, mxREAL);
      v = (float*)mxGetPr(plhs[1]);
    }
  } else if(nlhs == 1) {
    plhs[0] = mxCreateNumericMatrix (nev, 1, mxSINGLE_CLASS, mxREAL);
    s = (float*)mxGetPr(plhs[0]);    
  }

  int ret = fmat_svd_partial(d, n, nev, (float*)mxGetPr(prhs[0]), 
                             s, u, v); 
  
  if(ret <= 0) {
    mexErrMsgTxt("Did not find any singluar value.");    
  }

  if(ret != nev) {    
    fprintf(stderr, "WARN only %d / %d singular values converged\n", ret, nev); 
  }

}
