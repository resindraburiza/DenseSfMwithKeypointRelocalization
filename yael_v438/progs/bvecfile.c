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

/* Display a set of vector stored in a vector float format */

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>
#include <assert.h>


#define FMT_TXT     0
#define FMT_BVECS   3

void display_help (const char * progname)
{
  fprintf (stderr, "%s reads a fvecfile on standard input\n", progname);
  exit (0);
}


int main (int argc, char **argv) 
{
  int i, j, d, ret;
  int n = INT_MAX;       /* maximum number of vectors to be read */
  int maxd = 500000000;  /* maximum number of dimension */
  int out_fmt = FMT_TXT; /* output to binary byte stream */         

  FILE * fi = stdin;
  FILE * fo = stdout;

  /* read the arguments */
  for (i = 1 ; i < argc ; i++) {
    char *a = argv[i];

    if (!strcmp (a, "-n") && i + 1 < argc) {
      ret = sscanf (argv[++i], "%d", &n);
      assert (ret == 1);
    } 
    else if (!strcmp (a, "-maxd") && i + 1 < argc) {
      ret = sscanf (argv[++i], "%d", &maxd);
      assert (ret == 1);
    } 
    else if (!strcmp (a, "-bvecs") && i + 1 < argc) {
      fo = fopen (argv[++i], "w");
      out_fmt = FMT_BVECS;
      assert (fo);
    }
    else {
      fprintf (stderr, "could not parse argument %s\n", a);
      display_help (argv[0]);
    }
  }

  /* Read the values while there are some */
  float * v = malloc (sizeof (*v) * maxd);
  unsigned char * vb = malloc (sizeof (*vb) * maxd);

  i = 0;
  while (!feof (fi) && i < n) {
    ret = fread (&d, sizeof (d), 1, fi);

    if (ret == 0)
      break;

    assert (d < maxd); 
    ret = fread (v, sizeof (*v), d, fi);
    assert (ret == d);
    
    if (out_fmt == FMT_TXT) {
      fprintf (fo, "[");
      for (j = 0 ; j < d ; j++)
	fprintf (fo, "%.5f ", v[j]);
      fprintf (fo, "]\n");
    }
    else if (out_fmt == FMT_BVECS) {
      for (j = 0 ; j < d ; j++)
	vb[j] = (unsigned char) v[j];
      ret = fwrite (&d, sizeof (d), 1, fo);
      assert (ret == 1);
      ret = fwrite (vb, sizeof (*vb), d, fo);
      assert (ret == d);
    }
    i++;
  }

  free (v);
  fprintf (stderr, "found %d vectors\n", i);
  fclose (fo);
  return 0;
}


