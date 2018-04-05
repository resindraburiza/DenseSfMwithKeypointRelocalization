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

/* This code was written by Herve Jegou. Contact: herve.jegou@inria.fr  */
/* Last change: June 1st, 2010                                          */
/* This software is governed by the CeCILL license under French law and */
/* abiding by the rules of distribution of free software.               */
/* See http://www.cecill.info/licences.en.html                          */

#include <assert.h>
#include <string.h>
#include "mex.h"
#include "../yael/hamming.h"
#include "../yael/machinedeps.h"

#ifdef _OPENMP
#include <omp.h>
#endif


void usage (const char * msg) 
{
  char msgtot[1024];
  const char * msgusg = 
    "There are two modes, depending on whether a threshold is given or not\n\n"
    "H = yael_hamming (X, Y);\n\n"
    "       X and Y are set of compact bit vectors (uint8), 1 per column\n"
    "       H is the set of all Hamming distances, in uint16 format\n\n"
    "[ids, hdis] = yael_hamming (X, Y, thres);\n"
    "       ids: matching elements, thres: hamming threshold\n";
  
  sprintf (msgtot, "%s\n\n%s\n", msg, msgusg);
  mexErrMsgTxt (msgtot);
}


void mexFunction (int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray*prhs[])

{
  int mode_thres = 0;
  if (nrhs != 2 && nrhs != 3) 
    mexErrMsgTxt ("This function requires either 2 input arguments.");
  
  if (nrhs == 3) mode_thres = 1; 
  
  int d = mxGetM (prhs[0]);   /* d is the number of codes, i.e., 8 times the number of bits */
  int na = mxGetN (prhs[0]);
  int nb = mxGetN (prhs[1]);

  if (mxGetM (prhs[1]) != d) 
      usage ("Dimension of binary vectors are not consistent");

  if (mxGetClassID(prhs[0]) != mxUINT8_CLASS)
    	usage ("first argument should be uint 8 type"); 

  if (mxGetClassID(prhs[1]) != mxUINT8_CLASS)
      usage ("second argument should be uint8 type"); 

  uint8 * a = (uint8*) mxGetPr (prhs[0]);
  uint8 * b = (uint8*) mxGetPr (prhs[1]);


  /* Just compute all Hamming distances */
  if (mode_thres == 0) {
    if (nlhs > 1)
      usage ("This syntax expects only exactly one output argument");

    /* ouptut: distances */
    plhs[0] = mxCreateNumericMatrix (na, nb, mxUINT16_CLASS, mxREAL);
    uint16 *dis = (uint16*) mxGetPr (plhs[0]);

    compute_hamming (dis, a, b, na, nb, d);
  }
  
  /* Return only the Hamming distances below a given threshold */
  else {
    if (nlhs != 2)
      usage ("This syntax expects only exactly two output arguments");
    int ht = (int) mxGetScalar (prhs[2]);
    size_t totmatches;
    int * keys;
    uint16 *dis;
    size_t i;
    
/* #ifndef _OPENMP */
    match_hamming_count (a, b, na, nb, ht, d, &totmatches);
    
    plhs[0] = mxCreateNumericMatrix (2, totmatches, mxINT32_CLASS, mxREAL);
    plhs[1] = mxCreateNumericMatrix (1, totmatches, mxUINT16_CLASS, mxREAL);
    
    keys = (int *) mxGetPr(plhs[0]);
    dis = (uint16*) mxGetPr (plhs[1]);
    
    size_t ret = match_hamming_thres_prealloc (a, b, na, nb, ht, d, keys, dis);
 
    assert (ret == totmatches);

    /* Fix Matlab identifiers */
    for (i = 0 ; i < 2 * totmatches ; i++)
      keys[i] = keys[i] + 1;
  }
            
}

