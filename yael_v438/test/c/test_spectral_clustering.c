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
#include <stdlib.h>
#include <math.h>

#include <yael/spectral_clustering.h>
#include <yael/vector.h>

int main()
{
  int i, d = 2;

  int n1 = 20, n2 = 30, n = n1 + n2;
  //  int n1 = 5, n2 = 5, n = n1 + n2;
  double r1 = 1, r2 = 2;
  float * v = fvec_new (n * 2);

  for (i = 0 ; i < n1 ; i++) {
    v[i * d + 0] = r1 * cos (i * (double) 0.1);
    v[i * d + 1] = r1 * sin (i * (double) 0.1);
  }
  for (i = n1 ; i < n ; i++) {
    v[i * d + 0] = r2 * cos (i * (double) 0.1);
    v[i * d + 1] = r2 * sin (i * (double) 0.1);
  } 

  for (i = 0 ; i < n ; i++)
    fvec_print (v + i * d, d);

  int k = 2;
  int * assign = ivec_new (n);
  int * nassign = ivec_new (k);
  double sigma = 0.5;
  int niter = 40;
  int nt = 1;
  int seed = 0;
  int nredo = 4;
  spectral_clustering (d, n, k, sigma, niter, v, nt, seed, nredo, assign, nassign);

  printf ("nassign = "); ivec_print (nassign, k);
  printf ("assign = "); ivec_print (assign, n);


  free (v);
  return 0;
}
