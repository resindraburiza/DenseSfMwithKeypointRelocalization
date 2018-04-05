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

/* C front-end for the kmeans function */

#include <string.h>
#include <stdlib.h> 
#include <stdio.h>
#include <assert.h> 

#include <yael/vector.h>
#include <yael/machinedeps.h>
#include <yael/kmeans.h>

#define FMT_FVEC  0
#define FMT_TEXT  1

#define DEFAULT_NITER 40
#define DEFAULT_NREDO 1

void usage(const char * cmd)
{
  printf ("Usage: %s [options]\n", cmd);
  
  printf (
	  "  Input\n"
	  "    -i filename     input set of vectors to cluster (fvec file format)\n"
	  "    -itxt filename  the same but for an input text file\n"
	  "    -n #            use n points from the file. Default: all the vectors\n"
          "    -d #            dimension of the vector (used with -itxt only)\n"
	  "  Clustering parameters\n"                  
	  "    -k #            number of centroids to produce\n"
	  "    -niter #        maximum number of iterations. Default: %d\n"
	  "    -nredo #        number of runs to perform. Default: %d\n"
	  "    -seed #         initialize the random generate with a number\n"
          "    -nt #           number of threads used. Default: nt=all\n"
	  "  Ouput\n"                          
	  "    -o clustfile    output cluster file (fvec format)\n"
	  "    -otxt clustfile output cluster file (text format)\n", 
	  DEFAULT_NITER, DEFAULT_NREDO);
  exit (0);
}



int main (int argc, char ** argv)
{
  int i;
  int k = 10;
  int d = 0;
  int n = 0;
  int niter = DEFAULT_NITER;
  int nredo = DEFAULT_NREDO;
  int nt = count_cpu();
  int seed = 0;
  int ret;
  int fmt_in = FMT_FVEC;
  int fmt_out = FMT_FVEC;

  const char * fi_name = NULL;
  const char * fo_name = NULL;

  if (argc == 1)
    usage (argv[0]);

  for (i = 1 ; i < argc ; i++) {
    char *a = argv[i];

    if (!strcmp (a, "-h") || !strcmp (a, "--help"))
      usage (argv[0]);

    if (!strcmp (a, "-k") && i+1 < argc) {
      ret = sscanf (argv[++i], "%d", &k);
      assert (ret);
    }
    if (!strcmp (a, "-d") && i+1 < argc) {
      ret = sscanf (argv[++i], "%d", &d);
      assert (ret);
    }
    else if (!strcmp (a, "-n") && i+1 < argc) {
      ret = sscanf (argv[++i], "%d", &n);
      assert (ret);
    }
    else if (!strcmp (a, "-niter") && i+1 < argc) {
      ret = sscanf (argv[++i], "%d", &niter);
      assert (ret);
    }
    else if (!strcmp (a, "-nt") && i+1 < argc) {
      ret = sscanf (argv[++i], "%d", &nt);
      assert (ret);
    }
    else if (!strcmp (a, "-nredo") && i+1 < argc) {
      ret = sscanf (argv[++i], "%d", &nredo);
      assert (ret);
    }
    else if (!strcmp (a, "-seed") && i+1 < argc) {
      ret = sscanf (argv[++i], "%d", &seed);
      assert (ret);
    }
    else if (!strcmp (a, "-i") && i+1 < argc) {
      fi_name = argv[++i];
    }
    else if (!strcmp (a, "-itxt") && i+1 < argc) {
      fi_name = argv[++i];
      fmt_in = FMT_TEXT;
    }
    else if (!strcmp (a, "-o") && i+1 < argc) {
      fo_name = argv[++i];
    }
    else if (!strcmp (a, "-otxt") && i+1 < argc) {
      fo_name = argv[++i];
      fmt_out = FMT_TEXT;
    }
  }

  assert (fi_name && fo_name);

  fprintf (stderr, "k = %d\nd = %d\nn = %d\nniter = %d\nnredo = %d\n",
	   k, d, n, niter, nredo);
  fprintf (stderr, "nt = %d\nseed = %d\n", nt, seed);
  fprintf (stderr, "fi = %s  (fmt = %s)\n", fi_name, 
	   (fmt_in == FMT_FVEC ? "fvec" : "txt"));
  fprintf (stderr, "fo = %s  (fmt = %s)\n", fo_name, 
	   (fmt_out == FMT_FVEC ? "fvec" : "txt"));

  /* read the input vectors */
  float * v;

  /* read the vectors from the input file, and sanitize them if needed */
  if (fmt_in == FMT_FVEC) {
    if (d == 0 || n == 0) {/* automatically read the dimension */
      int ret = fvecs_fsize (fi_name, &d, &n);
      fprintf (stderr, "File %s contains (%d bytes) %d vectors of dimension %d\n", fi_name, ret, n, d);
      assert (ret);    
    }
    v = fvec_new (n * d);
    ret = fvecs_read (fi_name, d, n, v);
  }
  else if (fmt_in == FMT_TEXT) {
    v = fvec_new (n * d);
    ret = fvecs_read_txt (fi_name, d, n, v);
  }
  else exit (1);

  assert (ret >= n);

  /* Remove the Nan values */
  int nNaN = fvec_purge_nans (v, n * d, 2);
  if (nNaN > 0)
    fprintf (stderr, "found %d NaN values\n", nNaN);

  /* k-means! */
  float * centroids = fvec_new (k * d);
  int * nassign = ivec_new (k);
  kmeans (d, n, k, niter, v, nt, seed, nredo, centroids, NULL, NULL, nassign);


  /* write the output file */
  if (fmt_out == FMT_FVEC)
    ret = fvecs_write (fo_name, d, k, centroids);
  else if (fmt_out == FMT_TEXT)
    ret = fvecs_write_txt (fo_name, d, k, centroids);
  else exit (2);
  assert (ret == k);
  
  free (centroids);
  free (nassign);
  free (v);
  return 0;
}
