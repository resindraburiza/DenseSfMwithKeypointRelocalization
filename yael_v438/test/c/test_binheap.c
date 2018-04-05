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

#include <stdlib.h>
#include <limits.h>
#include <stdio.h>

#include <yael/binheap.h>


int main (int argc, char ** argv)
{
  int n = 10000, k = 10;
  int i;
  float * v = malloc (n * sizeof (v));
  int * bestidx = malloc (k * sizeof (*bestidx));
  float * bestval = malloc (k * sizeof (*bestval));

  for (i = 0 ; i < n ; i++) {
    v[i] = rand() / (double) INT_MAX;
  }

  fbinheap_t * bh = fbinheap_new (k);
    
  for (i = 0 ; i < n ; i++) 
    fbinheap_add (bh, i, v[i]);

  fbinheap_sort (bh, bestidx, bestval);
  for (i = 0 ; i < k ; i++)
    printf ("%d %.5g / ", bestidx[i], bestval[i]);
  printf ("\n");

  return 0;
}
