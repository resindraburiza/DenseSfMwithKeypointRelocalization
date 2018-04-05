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

#define SIFTGEO_DIM_META  9

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

#ifdef HAVE_OCTAVE
#define mwSize long
#endif

  /* For the filename */
  mwSize buflen;

  char *fsiftgeo_name;
  FILE * fsiftgeo;
  long n;
  int i, j, ret, dv = 128, siftgeo_size;

  /* SIFT descriptors and associated meta-data */
  float * v;
  float * meta;
  unsigned char * fbuffer;

  /* check for proper number of arguments */
  if(nrhs<1 || nrhs>3)
    mexErrMsgTxt("Usage: [v,g]=siftgeo_read(filename, num. dimensions).");
  else if(nlhs > 2)
    mexErrMsgTxt("Too many output arguments.");

  /* input must be a string */
  if (mxIsChar(prhs[0]) != 1)
    mexErrMsgTxt("Input must be a string.");

  /* input must be a row vector */
  if (mxGetM(prhs[0])!=1)
    mexErrMsgTxt("Input must be a row vector.");

    /* optionally read another argument to read a dimensions of input */
  if (nrhs == 2)
    dv = (int) mxGetScalar (prhs[1]);
  siftgeo_size = dv+40;


  /* get the length of the input string */
  buflen = (mxGetM(prhs[0]) * mxGetN(prhs[0])) + 1;

  /* copy the string data from prhs[0] into a C string input_ buf.    */
  fsiftgeo_name = mxArrayToString(prhs[0]);

  if(fsiftgeo_name == NULL) {
    mxFree(fsiftgeo_name);
    mexErrMsgTxt("Could not convert input to string.");
  }

  /* open the file for reading and retrieve it size */
  fsiftgeo = fopen (fsiftgeo_name, "r");
  if (!fsiftgeo)
    mexErrMsgTxt("Could not open the input file");
  mxFree(fsiftgeo_name);

  fseek (fsiftgeo, 0, SEEK_END);
  n = ftell (fsiftgeo) / siftgeo_size;
  fseek (fsiftgeo, 0, SEEK_SET);



  /* or directly specify the start and the end */
  if (nrhs == 3) {
    int posstart = 1; /*(int) mxGetScalar (prhs[1]) TO BE CHANGED */;
    int posend = (int) mxGetScalar (prhs[2]);
    if (posend < posstart || posstart < 1 || posend < 1)
      mexErrMsgTxt("Invalid boundaries");
    n = posend - posstart + 1;
    fseek (fsiftgeo, (posstart - 1) * siftgeo_size, SEEK_SET);
  }

   /* Read all the data using a single read function, and close the file */
  fbuffer = malloc (n * siftgeo_size);
  ret = fread (fbuffer, sizeof (*fbuffer), n * siftgeo_size, fsiftgeo);
  if (ret != n * siftgeo_size)
    mexErrMsgTxt("Unable to read correctly from the input file");
  fclose (fsiftgeo);

  const mwSize dimv[2] = {dv, n};
  const mwSize dimmeta[2] = {SIFTGEO_DIM_META, n};

  /* Allocate the output matrices */
  plhs[0] = mxCreateNumericArray(2, dimv, mxSINGLE_CLASS, mxREAL);
  v = (float *) mxGetPr(plhs[0]);

  if (nlhs > 1) {
    plhs[1] = mxCreateNumericArray(2, dimmeta, mxSINGLE_CLASS, mxREAL);
    meta = (float *) mxGetPr(plhs[1]);
  }

  /* Copy the data from the buffer into these variables */
  for (i = 0 ; i < n ; i++) {

    for (j = 0 ; j < dv ; j++)
      v[j + dv * i] = fbuffer[i * siftgeo_size + j
	      + SIFTGEO_DIM_META * sizeof (float) + sizeof (int)];

    if (nlhs > 1) {
      float * fbuf = (float *) (fbuffer + i * siftgeo_size);
      for (j = 0 ; j < SIFTGEO_DIM_META ; j++)
        meta[j + SIFTGEO_DIM_META * i] = fbuf[j];
    }
  }
  free (fbuffer);
}
