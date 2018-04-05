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
#include <assert.h>

#include <yael/eigs.h>
#include <yael/vector.h>
#include <yael/matrix.h>

int main()
{
  int i, j, k, d = 10,d2=5;
  float * a = fvec_new (d * d);
  float * b = fvec_new (d * d);
  float * b0 = fvec_new (d * d);
#define B0(i,j) b0[(i)+(j)*d]
#define A(i,j) a[(i)+(j)*d]
#define B(i,j) b[(i)+(j)*d] 
  float * lambda = fvec_new (d);
  float * v = fvec_new (d * d);
  float *v_part=fvec_new (d * d2);

  for (i = 0 ; i < d ; i++)
    for (j = 0 ; j  <= i ; j++) {
      A(i,j) = A(j,i) = drand48(); 
      B0(i,j)=drand48();
      B0(j,i)=drand48();
      
/*      B(i,j) = B(j,i) = drand48(); */
    }
  /* make a positive definite b (with b=b0*b0') */
  for (i = 0 ; i < d ; i++)
    for (j = 0 ; j  < d ; j++) {
      double accu=0;
      for(k=0;k<d;k++) 
        accu+=B0(i,k)*B0(j,k);
      B(i,j)=accu;
    }

  printf ("a = ");
  fmat_print(a,d,d);

  printf ("\nb = "); 
  fmat_print(b,d,d);

  printf ("Solution of the eigenproblem Av=lambda v\n");
  
  printf ("\n");
  int ret=eigs_sym (d, a, lambda, v);
  assert(ret==0);
  printf ("\n");


  printf("Eigenvectors:\n");
  fmat_print(v,d,d);

  fprintf(stdout, "lambda = ");
  fvec_print (lambda, d);
  printf ("\n");

  printf("Partial eigenvalues/vectors:\n");

  printf ("\n");
  ret=eigs_sym_part (d, a, d2, lambda, v_part);
  assert(ret>0);
  if(ret<d2) 
    printf("!!! only %d / %d eigenvalues converged\n",ret,d2);

  printf ("\n");

  printf("Eigenvectors:\n");
  fmat_print(v_part,d,d2);
  
  fprintf(stdout, "lambda = ");
  fvec_print (lambda, d2);
  printf ("\n");

   
  printf ("Solution of the generalized eigenproblem Av=lambda B v\n");

  printf ("\n");
  ret=geigs_sym (d, a, b, lambda, v);
  assert(ret==0);
  printf ("\n");

  fmat_print(v,d,d);

  fprintf(stdout, "lambda = ");
  fvec_print (lambda, d);
  printf ("\n");

  free (a);
  free (lambda);
  free (v);

  return 0;
}
