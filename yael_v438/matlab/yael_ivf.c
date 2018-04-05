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

#include <yael/ivf.h>
#include <yael/hamming.h>
#include "mex.h"
#include <string.h>

/* The different possible functions */
#define IVF_FUNCTION_STATUS            0
#define IVF_FUNCTION_NEW               1
#define IVF_FUNCTION_FREE              2
#define IVF_FUNCTION_ADD               3
#define IVF_FUNCTION_LOAD              4
#define IVF_FUNCTION_SAVE              5
#define IVF_FUNCTION_GETIDS            6
#define IVF_FUNCTION_GETBINSIG         7
#define IVF_FUNCTION_QUERYHE           8
#define IVF_FUNCTION_IMBFACTOR         9
#define IVF_FUNCTION_QUERYHEW          10
#define IVF_FUNCTION_FINDBS  		       12
#define IVF_FUNCTION_CROSSMATCH        20
#define IVF_FUNCTION_CROSSMATCH_ALT    22
#define IVF_FUNCTION_CROSSMATCH_COUNT  25

static ivf_t * ivf = NULL;

/* the buffers associated with the voting area (matches).
   This size will be expanded using geometric re-allocation so that it fits
   the maximum amount of memory needed after a few queries */
#define DEFAULT_NB_MATCHES (1 << 20);
static int bufmatch_size = DEFAULT_NB_MATCHES;


int ivfmex_status (int verbose)
{
  int i, j;
  
  if (ivf == NULL) return 0;

  mexPrintf("k=%d lists\n", ivf->k);
  mexPrintf("elem_size=%d\n", ivf->elem_size);
  mexPrintf("n=%d vectors stored\n\n", ivf->n);

  if (verbose >= 1) {
    mexPrintf("Inverted lists:nbelems/nballocs\n");
    for (i = 0 ; i < ivf->k ; i++) 
      mexPrintf("%d/%d  ", ivf->nbelems[i], ivf->seg_size[i]);
    mexPrintf("\n");
  }
  if (verbose >= 2) {
    for (i = 0 ; i < ivf->k ; i++) {
      mexPrintf("List %-7d -> ", i);
      for (j = 0 ; j < ivf->nbelems[i] ; j++) 
        mexPrintf("%d  ", ivf->ids[i][j]);
      mexPrintf("\n");
    }
  }
  return ivf->n;
}

/* Check empirically if the inverted file start at 0.
   Return */

#define IVF_MATLAB    1    /* likely to be matlab */
#define IVF_FROM0     0    /* should be C (idx at 0) */
int ivfmex_offsetidx()
{
  if (ivf->nbelems[0] == 0 && ivf->nbelems[1] > 0)
    return IVF_MATLAB;

  return IVF_FROM0;
}


void mexFunction (int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray*prhs[])

{
  long i;
  int operation = 0;
  char varname[256];
  int verbose = 0;

  /* First select which operation is to be performed */
  if (nrhs < 1 || mxGetClassID(prhs[0]) != mxCHAR_CLASS) 
    mexErrMsgTxt ("First argument must be defined and be a string (new|add|query)");
  if (mxGetString (prhs[0], varname, 256) != 0)
    mexErrMsgTxt ("Could not convert string data");

  if (!strcmp(varname, "status")) 
    operation = IVF_FUNCTION_STATUS;
  else if (!strcmp(varname, "queryhe")) 
    operation = IVF_FUNCTION_QUERYHE;
  else if (!strcmp(varname, "queryhew")) 
    operation = IVF_FUNCTION_QUERYHEW;
  else if (!strcmp(varname, "new")) 
    operation = IVF_FUNCTION_NEW;
  else if (!strcmp(varname, "free")) 
    operation = IVF_FUNCTION_FREE;
  else if (!strcmp(varname, "add")) 
    operation = IVF_FUNCTION_ADD;
  else if (!strcmp(varname, "load")) 
    operation = IVF_FUNCTION_LOAD;
  else if (!strcmp(varname, "save")) 
    operation = IVF_FUNCTION_SAVE;
  else if (!strcmp(varname, "getids")) 
    operation = IVF_FUNCTION_GETIDS;
  else if (!strcmp(varname, "imbfactor")) 
    operation = IVF_FUNCTION_IMBFACTOR;
  else if (!strcmp(varname, "findbs")) 
    operation = IVF_FUNCTION_FINDBS;
  else if (!strcmp(varname, "crossmatch")) 
    operation = IVF_FUNCTION_CROSSMATCH;
  else if (!strcmp(varname, "crossmatchalt")) 
    operation = IVF_FUNCTION_CROSSMATCH_ALT;
  else if (!strcmp(varname, "crossmatchcount")) 
    operation = IVF_FUNCTION_CROSSMATCH_COUNT;
  else mexErrMsgTxt("Unknown operation for this inverted file");  
  

  switch (operation) {
  case IVF_FUNCTION_STATUS: {
    if (nrhs > 1) 
      verbose = (int) mxGetScalar (prhs[1]);

    plhs[0] = mxCreateNumericMatrix (1, 1, mxUINT64_CLASS, mxREAL);
    long long * retptr = (long long *) mxGetPr (plhs[0]);
    * retptr = ivfmex_status (verbose);
  }
    break;

  case IVF_FUNCTION_NEW:
 
    if (nlhs != 0)
      mexErrMsgTxt ("This function returns no value (just allocated the IVF)");
    if (nrhs != 3 && nrhs != 4) 
      mexErrMsgTxt ("Invalid number of input arguments");
    if (ivf != NULL)
      mexErrMsgTxt ("Inverted file already allocated.\n"
		    "It should be free before being invoking new.");

    int coarsek = (int) mxGetScalar (prhs[1]);
    int elemsize = (int) mxGetScalar (prhs[2]);
    int segsize = DEFAULT_SEG_SIZE;
    if (nrhs == 4)
      segsize = (int) mxGetScalar (prhs[3]);

    /* Produce an inverted file */
#ifndef __SSE4_2__
    #warning No SSE4 -> code will not be ultimately optimized
#endif
    ivf = ivf_new (coarsek, elemsize, segsize);

    /* Give default value to the size of the voting buffer */
    bufmatch_size = DEFAULT_NB_MATCHES;
    return;


  case IVF_FUNCTION_FREE:
    if (nlhs != 0 || nrhs != 1)
      mexErrMsgTxt ("Usage: ivfmex('free')");
    ivf_delete (ivf);
    ivf = NULL;
    return;


  case IVF_FUNCTION_ADD: {
    if (nlhs != 0)
      mexErrMsgTxt ("Usage: ivfmex ('queryhe', ids, keys, codes, ht)\n"
		    "This function outputs no argument");
    if (nrhs != 4) 
      mexErrMsgTxt ("Usage: ivfmex ('queryhe', ids, keys, codes, ht)\n");

    if (mxGetClassID(prhs[1]) != mxINT32_CLASS || mxGetM (prhs[1]) != 1)
      mexErrMsgTxt ("Argument 2 should a vector of int32 ids"); 
    int n = mxGetN (prhs[1]);
    int * ids = (int *) mxGetPr (prhs[1]);

    if (mxGetClassID(prhs[2]) != mxINT32_CLASS)
      mexErrMsgTxt ("Argument 3 is be the set of indexes (visual words), of type int32"); 
    if (mxGetN (prhs[2])!= n || mxGetM(prhs[2]) != 1)
      mexErrMsgTxt ("Problem with Argument 3"); 
    int * keys = (int *) mxGetPr (prhs[2]);
    
    if (mxGetClassID(prhs[3]) != mxUINT8_CLASS)
      mexErrMsgTxt ("Argument 4 should be the set of codes (nbytes_per_codes * n)"); 
    if (mxGetN (prhs[3])!= n || mxGetM(prhs[3]) != ivf->elem_size)
      mexErrMsgTxt ("Problem with Argument 4"); 
    uint8 * codes = (uint8 *) mxGetPr (prhs[3]);

    ivf_addn (ivf, ids, keys, codes, n);
  }
    return;

  case IVF_FUNCTION_SAVE: {
    if (nlhs != 0 || nrhs != 2)
      mexErrMsgTxt ("Usage: ivfmex('save', filename)");
    if (ivf == NULL)
      mexErrMsgTxt ("ivfmex/save: IVFADC structured not initialized");

    char fname[512];
    if (mxGetClassID(prhs[1]) != mxCHAR_CLASS) 
      mexErrMsgTxt ("Argument 2 (filename) should be a string");         
     
    if (mxGetString (prhs[1], fname, 256) != 0)
      mexErrMsgTxt ("Could not convert string data");

    ivf_save (fname, ivf);
    }
    break;

  case IVF_FUNCTION_LOAD: {
    if (nlhs != 0 || nrhs != 2)
      mexErrMsgTxt ("Usage: ivfmex('load', filename)");
    if (ivf != NULL)
      mexErrMsgTxt ("ivfmex/load: free the structure before loading a new one from disk");

    char fname[512];
    if (mxGetClassID(prhs[1]) != mxCHAR_CLASS) 
      mexErrMsgTxt ("Argument 2 (filename) should be a string");         
     
    if (mxGetString (prhs[1], fname, 256) != 0)
      mexErrMsgTxt ("Could not convert string data");

    ivf = ivf_load (fname);
    }
    break;


  case IVF_FUNCTION_GETIDS:
    if (nlhs != 1)
      mexErrMsgTxt ("This function outputs 1 argument");
    if (nrhs != 2) 
      mexErrMsgTxt ("Usage: ids = ivfmex('getids', listid)");
    {
      int listno = (int) mxGetScalar (prhs[1]);
      int listlength = ivf_get_nb_elems (ivf, listno);

      /* mexPrintf ("listno=%d  listlength=%d\n", listno, listlength); */

      plhs[0] = mxCreateNumericMatrix (1, listlength, mxINT32_CLASS, mxREAL);
      int * ids = (int *) mxGetPr (plhs[0]);
      memcpy (ids, ivf_get_ids (ivf, listno), sizeof(int) * listlength);
    }
    break;


  case IVF_FUNCTION_IMBFACTOR:
    if (nlhs != 1)
      mexErrMsgTxt ("This function outputs 1 argument");
    if (nrhs != 1) 
      mexErrMsgTxt ("Usage: imbf = ivfmex('imbfactor')");
    if (ivf == NULL)
      mexErrMsgTxt ("Inverted file is not defined\n Use ivfmex('new',...).");
    { 
      plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);
      double *imbf = mxGetPr(plhs[0]);
      *imbf = ivf_imbalance_factor (ivf);
    }
    break;


  case IVF_FUNCTION_FINDBS:
    if (nlhs != 1)
      mexErrMsgTxt ("This function outputs 1 argument");
    if (nrhs != 3) 
      mexErrMsgTxt ("Usage: bs = ivfmex('findbs', key, ids)");
    if (ivf == NULL)
      mexErrMsgTxt ("Inverted file is not defined\n Use ivfmex('new',...).");
    { 
			int * keys = (int *) mxGetPr (prhs[1]);
			int * ids = (int *) mxGetPr (prhs[2]);
			int n = mxGetM (prhs[2]);

			uint8 * bs_ = ivf_find_vals (ivf, keys, ids, n);
			
			if (!bs_)
				mexErrMsgTxt ("Wrong pairs of keys and ids...");
     
			plhs[0] = mxCreateNumericMatrix (ivf->elem_size, n, mxUINT8_CLASS, mxREAL);
      uint8 * bs = (uint8 *) mxGetPr (plhs[0]);
      memcpy (bs, bs_, sizeof(uint8) * ivf->elem_size *n);

   		free (bs_);
    }
    break;


  case IVF_FUNCTION_QUERYHE: 

    if (nlhs != 1 || nrhs != 5)
      mexErrMsgTxt ("Usage: matches = ivfmex ('queryhe', ids, keys, codes, ht)");

    if (mxGetClassID(prhs[1]) != mxINT32_CLASS || mxGetM (prhs[1]) != 1)
      mexErrMsgTxt ("Argument 2 should a vector of int32 ids"); 

    if (ivf == NULL)
      mexErrMsgTxt ("Inverted file is not defined\n Use ivfmex('new',...).");
    {
    int nq = mxGetN (prhs[1]);
    int * qids = (int *) mxGetPr (prhs[1]);

    if (mxGetClassID(prhs[2]) != mxINT32_CLASS)
      mexErrMsgTxt ("Argument 3 is be the set of indexes (visual words), of type int32"); 
    if (mxGetN (prhs[2])!= nq || mxGetM(prhs[2]) != 1)
      mexErrMsgTxt ("Problem with Argument 3"); 
    int * keys = (int *) mxGetPr (prhs[2]);
    
    if (mxGetClassID(prhs[3]) != mxUINT8_CLASS)
      mexErrMsgTxt ("Argument 4 should be the set of codes (nbytes_per_codes * n)"); 
    if (mxGetN (prhs[3])!= nq || mxGetM(prhs[3]) != ivf->elem_size)
      mexErrMsgTxt ("Problem with Argument 4"); 
    uint8 * codes = (uint8 *) mxGetPr (prhs[3]);

    /* Hamming threshold for Hamming Embedding */
    int ht = (int) mxGetScalar (prhs[4]);

    int nmatches = bufmatch_size;  /* a priori on the maximum number of matches */
    ivfmatch_t * matches = ivf_hequery (ivf, qids, keys, codes, nq, &nmatches, ht);

    /* Update the buffer matching size if needed */
    if (nmatches > bufmatch_size)
      bufmatch_size = nmatches;

    /* Cast the match structure into matlab vectors */
    plhs[0] = mxCreateNumericMatrix (3, nmatches, mxINT32_CLASS, mxREAL);

    int * matchinfo = (int *) mxGetPr (plhs[0]);
    int i;
    for (i = 0 ; i < nmatches ; i++) {
      matchinfo[i*3] = matches[i].qid;
      matchinfo[i*3+1] = matches[i].bid;
      matchinfo[i*3+2] = matches[i].score;
    }
    
    free (matches);
    }
    break;
    
  case IVF_FUNCTION_QUERYHEW: {
    if (nlhs != 2 || (nrhs != 5 && nrhs != 6 && nrhs != 7))
      mexErrMsgTxt ("Usage: [ids, scores] = ivfmex ('queryhe', ids, keys, codes, ht [,scoremap, listw])");

    if (mxGetClassID(prhs[1]) != mxINT32_CLASS || mxGetM (prhs[1]) != 1)
      mexErrMsgTxt ("Argument 2 should a vector of int32 ids"); 

    if (ivf == NULL)
      mexErrMsgTxt ("Inverted file is not defined\n Use ivfmex('new',...).");

      int nq = mxGetN (prhs[1]);
    int * qids = (int *) mxGetPr (prhs[1]);

    if (mxGetClassID(prhs[2]) != mxINT32_CLASS)
      mexErrMsgTxt ("Argument 3 is be the set of indexes (visual words), of type int32"); 
    if (mxGetN (prhs[2])!= nq || mxGetM(prhs[2]) != 1)
      mexErrMsgTxt ("Problem with Argument 3"); 
    int * keys = (int *) mxGetPr (prhs[2]);
    
    if (mxGetClassID(prhs[3]) != mxUINT8_CLASS)
      mexErrMsgTxt ("Argument 4 should be the set of codes (nbytes_per_codes * n)"); 
    if (mxGetN (prhs[3])!= nq || mxGetM(prhs[3]) != ivf->elem_size)
      mexErrMsgTxt ("Problem with Argument 4"); 
    uint8 * codes = (uint8 *) mxGetPr (prhs[3]);

    /* Hamming threshold for Hamming Embedding */
    int ht = (int) mxGetScalar (prhs[4]);

    /* Optionally, use a mapping function for scores and a weighting function for lists */
    float * score_map = NULL;
    float * list_w = NULL;
    
    if (nrhs >= 6) {
      if (mxGetClassID(prhs[5]) != mxSINGLE_CLASS)
        mexErrMsgTxt ("Argument 5 should be a single array to weight Hamming distances"); 
      score_map = (float *) mxGetPr (prhs[5]);
    }
      
    if (nrhs >= 7) {
      if (mxGetClassID(prhs[6]) != mxSINGLE_CLASS)
        mexErrMsgTxt ("Argument 6 should be a single array to weights the lists"); 
      
      if ( (mxGetN (prhs[6])==1 && mxGetM (prhs[6])==(ivf->k-1)) 
           || (mxGetN (prhs[6])==(ivf->k-1) && mxGetM (prhs[6])==1) ) {
        
        list_w = (float *) malloc (ivf->k * sizeof (*list_w));
        list_w[0] = 0;
        memcpy (list_w+1, (float *) mxGetPr (prhs[6]), (ivf->k-1) * sizeof(*list_w));
      }
      else mexErrMsgTxt ("Length of argument 6 should be equal to the number of inverted lists"); 
    }
      
    size_t nmatches;
    ivfmatch_t * matches = ivf_hequeryw (ivf, qids, keys, codes, nq, ht, &nmatches, score_map, list_w);

    fprintf (stderr, "Found %ld matches\n", nmatches);

    /* Cast the match structure into matlab vectors */
    plhs[0] = mxCreateNumericMatrix (2, nmatches, mxINT32_CLASS, mxREAL);
    plhs[1] = mxCreateNumericMatrix (1, nmatches, mxSINGLE_CLASS, mxREAL);

    int32_T * matchids = (int32_T *) mxGetPr (plhs[0]);
    float * matchscores = (float *) mxGetPr (plhs[1]);
    size_t i;

    for (i = 0 ; i < nmatches ; i++) {
      *(matchids++) = matches[i].qid;
      *(matchids++) = matches[i].bid;
      *(matchscores++) = matches[i].score;
    }
    
    free (matches);
    free (list_w);
    }
    break;
      
      
    case IVF_FUNCTION_CROSSMATCH: {
      if (nlhs != 2 || nrhs != 2)
         mexErrMsgTxt ("Usage: [matches, nmatches] = ivfmex ('crossmatch', ht)");
      
      if (ivf == NULL)
        mexErrMsgTxt ("Inverted file is not defined\n Use ivfmex('new',...).");
    
      int off = ivfmex_offsetidx();

      /* Hamming threshold for Hamming Embedding */
      int ht = (int) mxGetScalar (prhs[1]);
      
      size_t * nmatches = (size_t *) malloc (sizeof(*nmatches) * ivf->k);
      hammatch_t ** hmlist = ivf_he_collect_crossmatches (ivf, ht, nmatches);
      
      /* compute the cumulative number of matches */
      size_t * cumnmatches = (size_t *) malloc (sizeof (*cumnmatches) * (ivf->k+1));
      cumnmatches[0] = 0;
      for (i = 0 ; i < ivf->k ; i++)
        cumnmatches[i+1] = nmatches[i] + cumnmatches[i];
      size_t totmatches = cumnmatches[ivf->k];
          
      /* Cast the match structure into matlab vectors */
      plhs[0] = mxCreateNumericMatrix (3, totmatches, mxINT32_CLASS, mxREAL);
      plhs[1] = mxCreateNumericMatrix (1, ivf->k-1, mxINT64_CLASS, mxREAL);
      
      memcpy (mxGetPr(plhs[1]), nmatches + off, sizeof (*nmatches) * (ivf->k-1));
      
      int * matchinfo = (int *) mxGetPr (plhs[0]);
      int i, j;
      
      for (j = off ; j < ivf->k - 1 + off ; j++)
        for (i = 0 ; i < nmatches[j] ; i++) {
          *(matchinfo++) = hmlist[j][i].qid;
          *(matchinfo++) = hmlist[j][i].bid;
          *(matchinfo++) = hmlist[j][i].score;
        }
    
      for (i = 0 ; i < ivf->k ; i++)
        free (hmlist[i]);
      free (hmlist);
      free (cumnmatches);
      free (nmatches);
    }
      break;
      
    case IVF_FUNCTION_CROSSMATCH_ALT: {
      if ((nlhs != 3 && nlhs != 4) || nrhs != 2)
         mexErrMsgTxt ("Usage: [idx, hamdis, keys] = ivfmex ('crossmatchalt', ht)");    
      if (ivf == NULL)
        mexErrMsgTxt ("Inverted file is not defined\n Use ivfmex('new',...).");

      int off = ivfmex_offsetidx();

      /* Count the number of matches */
      int ht = (int) mxGetScalar (prhs[1]);
      
      size_t * nmatches = (size_t *) malloc (sizeof(*nmatches) * ivf->k);
      ivf_he_count_crossmatches (ivf, ht, nmatches);
      
      /* compute the cumulative number of matches */
      size_t * cumnmatches = (size_t *) malloc (sizeof (*cumnmatches) * (ivf->k+1));
      cumnmatches[0] = 0;
      for (i = 0 ; i < ivf->k ; i++)
        cumnmatches[i+1] = nmatches[i] + cumnmatches[i];
      size_t totmatches = cumnmatches[ivf->k];

            
      plhs[0] = mxCreateNumericMatrix (2, totmatches, mxINT32_CLASS, mxREAL);
      plhs[1] = mxCreateNumericMatrix (1, totmatches, mxUINT16_CLASS, mxREAL);
      plhs[2] = mxCreateNumericMatrix (1, ivf->k-1, mxINT64_CLASS, mxREAL);

      ivf_he_crossmatches_prealloc (ivf, ht, (int *) mxGetPr(plhs[0]), 
                                    (uint16 *) mxGetPr(plhs[1]), cumnmatches);
      
      memcpy (mxGetPr(plhs[2]), nmatches + off, sizeof (*nmatches) * (ivf->k-1)); 
      
      if (nlhs == 4) {
        plhs[3] = mxCreateNumericMatrix (1, totmatches, mxINT32_CLASS, mxREAL);
        int * key = (int *) mxGetPr(plhs[3]);
        long j;
        for (i = 0 ; i < ivf->k ; i++)
          for (j = cumnmatches[i] ; j < cumnmatches[i+1] ; j++) {
            key[j] = i;
          }
      }
      
      free (nmatches);
      free (cumnmatches);
    }
      break;
      
            
    case IVF_FUNCTION_CROSSMATCH_COUNT: {
      if (nlhs != 1 || nrhs != 2)
        mexErrMsgTxt ("Usage: nmatches = ivfmex ('crossmatchcount', ht)");
      
      if (ivf == NULL)
        mexErrMsgTxt ("Inverted file is not defined\n Use ivfmex('new',...).");
      
      int off = ivfmex_offsetidx();
      
      /* Hamming threshold for Hamming Embedding */
      int ht = (int) mxGetScalar (prhs[1]);
      
      size_t * nmatches = (size_t *) malloc (sizeof(*nmatches) * ivf->k);
      
      ivf_he_count_crossmatches (ivf, ht, nmatches);
      
      plhs[0] = mxCreateNumericMatrix (1, ivf->k-1, mxINT64_CLASS, mxREAL);
      memcpy (mxGetPr(plhs[0]), nmatches + off, sizeof (*nmatches) * (ivf->k-1));  
      free (nmatches);
    }
      break;
      
  }
}
