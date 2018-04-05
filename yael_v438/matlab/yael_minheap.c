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
#include <string.h>

#define ARGIN_VALH (prhs[0])
#define ARGIN_IDSH (prhs[1])
#define ARGIN_VAL  (prhs[2])
#define ARGIN_IDS  (prhs[3])

#define ARGOUT_VAL (plhs[0])
#define ARGOUT_IDS (plhs[1])


/* add n elements on the heap (the values are added only if they 
 are small enough compared to the other elements)            */
void fbinheap_add (int k, float * bh_val, int * bh_label, int n, const float * v, const int * label);

/* add n elements on the heap, using the set of labels starting at label0  */
void fbinheap_add_label_range (int k, float * bh_val, int * bh_label, int label0, int n, const float * v);

/* Main function */

void mexFunction (int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray*prhs[])

{
  if (nrhs != 4) 
    mexErrMsgTxt ("Invalid number of input arguments: either 2 for initialization or 4 for feeding the heap");
  
  if (nlhs != 2)
    mexErrMsgTxt ("2 output arguments are expected");
  
  if (mxGetClassID(ARGIN_VAL) != mxSINGLE_CLASS || mxGetClassID(ARGIN_VALH) != mxSINGLE_CLASS)
    mexErrMsgTxt ("need single precision array for values"); 
  
  if (mxGetClassID(ARGIN_IDS) != mxUINT32_CLASS || mxGetClassID(ARGIN_IDSH) != mxUINT32_CLASS)
    mexErrMsgTxt ("need uint32 arrays for indices"); 
  
  /* Variables defining the heap */
  int k = mxGetM (ARGIN_VALH);               /* Number of neighbors for the heap */
  int nh = mxGetN (ARGIN_VALH);              /* Number of heaps */

  if (mxGetM(ARGIN_IDSH) != k || mxGetN (ARGIN_IDSH) != nh)
    mexErrMsgTxt ("Inconsistent sizes for the heap parameters");
  
  /* Values to be considered for being added in the heap */
  int n = mxGetM (ARGIN_VAL);
  int nh2 = mxGetN (ARGIN_VAL);
  
  if (mxGetM(ARGIN_IDS) != n || mxGetN (ARGIN_IDS) != 1 || nh2 != nh)
    mexErrMsgTxt ("Invalid sizes for the values/indexes to be added");

  /* Pointer to the data to manipulate */  
  float * val = (float*) mxGetPr (ARGIN_VAL);
  int * ids = (int*) mxGetPr (ARGIN_IDS);


  /* Produce output heap and populate it */  
  ARGOUT_VAL = mxCreateNumericMatrix (k, nh, mxSINGLE_CLASS, mxREAL);
  ARGOUT_IDS = mxCreateNumericMatrix (k, nh, mxUINT32_CLASS, mxREAL);

  float * bh_val = (float*) mxGetPr (ARGOUT_VAL);
  int * bh_ids = (int*) mxGetPr (ARGOUT_IDS);

  memcpy (bh_val, mxGetPr (ARGIN_VALH), k * nh * sizeof (*bh_val));
  memcpy (bh_ids, mxGetPr (ARGIN_IDSH), k * nh * sizeof (*bh_ids));
  
  int i, j;
  for (j = 0 ; j < nh ; j++)
    fbinheap_add (k, bh_val + j * k, bh_ids + j * k, n, val + j * n, ids);
} 

/*--------------------------------*/
/* Simple binary heap             */
static void fbinheap_pop (int k, float * bh_val, int * bh_label)
{
  float val = bh_val[k];
  int i = 1, i1, i2;
  
  while (1) {
    i1 = i << 1;
    i2 = i1 + 1;
    
    if (i1 > k)
      break;
    
    if (i2 == k + 1 || bh_val[i1] > bh_val[i2]) {
      if (val > bh_val[i1])
        break;
      bh_val[i] = bh_val[i1];
      bh_label[i] = bh_label[i1];
      i = i1;
    } 
    else {
      if (val > bh_val[i2])
        break;
      
      bh_val[i] = bh_val[i2];
      bh_label[i] = bh_label[i2];
      i = i2;
    }
  }
  
  bh_val[i] = bh_val[k];
  bh_label[i] = bh_label[k];
}


static void fbinheap_push (int k, float * bh_val, int * bh_label, float val, int label)
{
  int i = k, i_father;
  
  while (i > 1) {
    i_father = i >> 1;
    if (bh_val[i_father] >= val)  /* the heap structure is ok */
      break; 
    
    bh_val[i] = bh_val[i_father];
    bh_label[i] = bh_label[i_father];
    
    i = i_father;
  }
  bh_val[i] = val;
  bh_label[i] = label;
}


/* Exported functions. */
void fbinheap_add (int k, float * bh_val, int * bh_label, int n, const float * v, const int * label)
{
  int i;
  bh_val--;  /* don't ask why */
  bh_label--;
  
  float lim=bh_val[1];
  for (i = 0 ; i < n; i++) {
    if(v[i]<lim) {
      fbinheap_pop (k, bh_val, bh_label);
      fbinheap_push (k, bh_val, bh_label, v[i], label[i]);
      lim=bh_val[1];
    }      
  }
}


void fbinheap_add_label_range (int k, float * bh_val, int * bh_label, int label0, int n, const float * v)
{
  int i;
  bh_val--;
  bh_label--;
  
  float lim=bh_val[1];
  for (i = 0 ; i < n; i++) { /* optimized loop for common case */
    if(v[i]<lim) {
      fbinheap_pop (k, bh_val, bh_label);
      fbinheap_push (k, bh_val, bh_label, label0+i, v[i]);
      lim=bh_val[1];
    }      
  }
}


