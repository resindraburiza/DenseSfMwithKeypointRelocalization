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

/* This file is a mex-matlab wrap for the nearest neighbor search function of yael */

#include <assert.h>
#include <math.h>
#include "mex.h"
#include <sys/time.h>


#include <yael/nn.h> 


void mexFunction (int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray*prhs[])

{
  if (nrhs < 2 || nrhs > 3) 
    mexErrMsgTxt ("Invalid number of input arguments");
  
  if (nlhs != 1)
    mexErrMsgTxt ("1 output arguments required");

  int d = mxGetM (prhs[0]);
  int na = mxGetN (prhs[0]);
  int nb = mxGetN (prhs[1]);

  if (mxGetM (prhs[1]) != d)
      mexErrMsgTxt("Dimension of base and query vectors are not consistent");
  
  
  if (mxGetClassID(prhs[0]) != mxSINGLE_CLASS 
      || mxGetClassID(prhs[1]) != mxSINGLE_CLASS )
    mexErrMsgTxt ("need single precision array"); 


  float *a = (float*) mxGetPr (prhs[0]);  
  float *b = (float*) mxGetPr (prhs[1]); 

  /* ouptut: centroids, assignment, distances */
  plhs[0] = mxCreateNumericMatrix (na, nb, mxSINGLE_CLASS, mxREAL);
  float *dis = (float*) mxGetPr (plhs[0]);

  compute_cross_distances (d, na, nb, a, b, dis);
}
