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

/* This file implements monomial embeddings as well as modulation, i.e., mappings 
   for shift-invariant match kernels as considered in the Vedaldi & Zisserman paper 
   on "Explicit Feature Maps" (PAMI'2012)
*/
 
#include <string.h>
#include <assert.h>
#include "mex.h"

#include <yael/embedding.h>

#define PARAM_X        prhs[0]
#define PARAM_THETA    prhs[1]
#define PARAM_AN       prhs[2]


void mexFunction (int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray*prhs[])

{
  int i;
  int N = 1;
  int p; /* order of polynomial */
    
  if (nrhs != 4) 
    mexErrMsgTxt ("Invalid number of input arguments: should be 4");
  
  if (nlhs != 1)
    mexErrMsgTxt ("1 output arguments are required");

  if (mxGetClassID(PARAM_X) != mxSINGLE_CLASS)
    mexErrMsgTxt ("First parameter must be a single precision matrix"); 
  if (mxGetClassID(PARAM_THETA) != mxSINGLE_CLASS)
    mexErrMsgTxt ("Second parameter (theta) must be a single precision matrix"); 
  if (mxGetClassID(PARAM_AN) != mxSINGLE_CLASS)
    mexErrMsgTxt ("Third parameter (an) must be a single precision matrix"); 
  if (mxGetClassID(prhs[3]) != mxCHAR_CLASS) 
     mexErrMsgTxt ("Four argument should be a string");         
  
          
  /* input vectors */
  int d = mxGetM (PARAM_X);  /* vector dimensionality */
  int n = mxGetN (PARAM_X);  /* number of input vectors */

  /* Optional argument regarding aggregation */
  if (nrhs == 4) {
    char varname[256]; 
    if (mxGetString (prhs[3], varname, 256) != 0)
       mexErrMsgTxt ("Could not convert string data");

    if (!strcmp(varname, "poly1")) {
      p = 1; 
      N = n;
    }
    else if (!strcmp(varname, "poly2")) {
      p = 2; 
      N = n;
    }
    else if (!strcmp(varname, "poly3")) {
      p = 3; 
      N = n;
    }
    else if (!strcmp(varname, "poly1agg")) {
      p = 1; 
      N = 1;      
    }
    else if (!strcmp(varname, "poly2agg")) {
      p = 2; 
      N = 1;      
    }
    else if (!strcmp(varname, "poly3agg")) {
      p = 3; 
      N = 1;
    }
    else mexErrMsgTxt ("Four argument should be a string");
  }
  
  
  /* angles */
  int d2 = mxGetM (PARAM_THETA); 
  int n2 = mxGetN (PARAM_THETA); 
  
  if (n2 == 1 && d2 > 1) {
    n2 = d2; d2 = 1; 
  }
  else if (n2 > 1 && d2 > 1)
    mexErrMsgTxt ("Fourier components should be given as a vector, not a matrix");
  
  /* Fourier components */
  int F = mxGetM (PARAM_AN);  /* components of Fourier embedding - 1*/
  int d3 = mxGetN (PARAM_AN);
  
  if (F == 1 && d3 > 1) {
    F = d3 - 1; 
    d3 = 1; }
  else F = F - 1; 
  
  if (n != n2) 
    mexErrMsgTxt ("Dimensions of param 1 and param 2 are not consistent");
  
  if (d2 != 1 || d3 != 1)   
    mexErrMsgTxt ("Param 2 and 3 should be vectors");
  

  const float * x = (float*) mxGetPr (PARAM_X);      /* the set of vectors to be embedded */
  const float * theta = (float*) mxGetPr (PARAM_THETA);  /* angles */
  const float * an = (float*) mxGetPr (PARAM_AN);     /* Fourier coefficients */
  
  for (i = 0 ; i <= F ; i++) 
    if (an[i] < 0) 
       mexErrMsgTxt ("All Fourier components should be positive");
    
  /* dimensionalities */
  int D;
  if (p == 1)
    D = d;
  else if (p == 2)
    D = EMB_POLY2_D(d); 
  else if (p == 3)
    D = EMB_POLY3_D(d);
  else assert (0);  
  
  int DF = D * (2 * F + 1);
  
  /* fprintf (stderr, "d=%d  D=%d  n=%d  d=%d  n2=%d  d2=%d  d3=%d  F=%d\n", d, D, n, d, n2, d2, d3, F); */
          
  plhs[0] = mxCreateNumericMatrix (DF, N, mxSINGLE_CLASS, mxREAL);
  float * y = (float*) mxGetPr (plhs[0]);
  
  /* embed the vectors */
  float * xe = (float *) calloc (D, sizeof(*xe));
  
  if (p == 1) {
    if (N == n) {
      for (i = 0 ; i < n ; i++) 
        ang_modulate (an, x + d * i, theta[i], y + DF * i, D, F);
      }
    else  {
      for (i = 0 ; i < n ; i++) {
        ang_modulate (an, x + d * i, theta[i], y, D, F);
      }
    }
  }
  else if (p == 2) {
    if (N == n) {
      for (i = 0 ; i < n ; i++) {
        emb_poly2 (x + d * i, xe, d);
        ang_modulate (an, xe, theta[i], y + DF * i, D, F);
      }
    }
    else  {
      for (i = 0 ; i < n ; i++) {
        emb_poly2 (x + d * i, xe, d);
        ang_modulate (an, xe, theta[i], y, D, F);
      }
    }
  }
  else if (p == 3) {
    if (N == n) {
      for (i = 0 ; i < n ; i++) {
        emb_poly3 (x + d * i, xe, d);
        ang_modulate (an, xe, theta[i], y + DF * i, D, F);
      }
    }
    else  {
      for (i = 0 ; i < n ; i++) {
        emb_poly3 (x + d * i, xe, d);
        ang_modulate (an, xe, theta[i], y, D, F);
      }
    }
  }
  
  free (xe);
}
