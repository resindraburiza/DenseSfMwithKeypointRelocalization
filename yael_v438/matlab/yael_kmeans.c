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

#include <yael/kmeans.h>
#include <yael/machinedeps.h>

#include "mex.h"


void mexFunction (int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray*prhs[])

{
  if (nrhs < 2 || nrhs % 2 != 0) 
    mexErrMsgTxt("even nb of input arguments required.");
  else if (nlhs > 4 || nlhs < 1) 
    mexErrMsgTxt("1 to 3 output arguments are expected.");

  int flags = 0;
  int d = mxGetM (prhs[0]);
  int n = mxGetN (prhs[0]);
  long seed = 0L;
  
  if(mxGetClassID(prhs[0])!=mxSINGLE_CLASS)
    mexErrMsgTxt("need single precision array.");

  float *v = (float*) mxGetPr (prhs[0]);
  int k = (int) mxGetScalar (prhs[1]);

  int niter = 50, redo = 1, nt = 1, verbose = 1;
  int init_type = 0;  /* random selection by default */

  {
    int i;
    for(i = 2 ; i < nrhs ; i += 2) {
      char varname[256];
      if (mxGetClassID(prhs[i]) != mxCHAR_CLASS) 
        mexErrMsgTxt ("variable name required");         

      if (mxGetString (prhs[i], varname, 256) != 0)
        mexErrMsgTxt ("Could not convert string data");

      if (!strcmp(varname, "niter")) 
        niter = (int) mxGetScalar (prhs[i+1]);

      else if (!strcmp(varname,"redo")) 
        redo = (int) mxGetScalar (prhs[i+1]);

      else if (!strcmp(varname,"seed")) 
        seed = (int) mxGetScalar (prhs[i+1]);

      else if (!strcmp(varname,"verbose")) 
        verbose = (int) mxGetScalar (prhs[i+1]);

      else if (!strcmp(varname,"init")) {
	init_type = (int) mxGetScalar (prhs[i+1]);
	assert (init_type == 0 || init_type == 1);
      }

      else 
        mexErrMsgTxt("unknown variable name");  
    }
  }
  
  if (init_type == 1)  /* Berkeley */
    flags = flags | KMEANS_INIT_BERKELEY;
  else if (init_type == 0) /* random vectors */
    flags = flags | KMEANS_INIT_RANDOM;
  

  flags |= nt;

  if (verbose > 0)
    printf("Input: %d vectors of dimension %d\nk=%d niter=%d "
	   "redo=%d verbose=%d seed=%d v1=[%g %g ...], v2=[%g %g... ]\n",
	   n, d, k, niter, redo, verbose, seed, v[0], v[1], v[d], v[d+1]); 
  else
    flags |= KMEANS_QUIET;
  

  if(n < k) {
    mexErrMsgTxt("fewer points than centroids");    
  }


  /* ouptut: centroids, assignment, distances */

  plhs[0] = mxCreateNumericMatrix (d, k, mxSINGLE_CLASS, mxREAL);
  float *centroids = (float*) mxGetPr (plhs[0]);

  float * dis = NULL;
  int * assign = NULL;
  int * nassign = NULL;

  if (nlhs == 2) {
    plhs[1] = mxCreateNumericMatrix (n, 1, mxINT32_CLASS, mxREAL);
    assign = (int*) mxGetPr (plhs[1]);
  }
  else if (nlhs >= 3) {
    plhs[1] = mxCreateNumericMatrix (n, 1, mxSINGLE_CLASS, mxREAL);
    dis = (float*) mxGetPr (plhs[1]);
    plhs[2] = mxCreateNumericMatrix (n, 1, mxINT32_CLASS, mxREAL);
    assign = (int*) mxGetPr (plhs[2]);
  }

  if (nlhs >=4)  {
    plhs[3] = mxCreateNumericMatrix (k, 1, mxINT32_CLASS, mxREAL);
    nassign = (int*) mxGetPr (plhs[3]);
  }

  kmeans (d, n, k, niter, v, flags, seed, 
	  redo, centroids, dis, assign, nassign);

  /* post-processing: Matlab starts from 1 */
  if (assign) {
    int i;
    for (i = 0 ; i < n ; i++)
      assign[i]++;
  }
}
