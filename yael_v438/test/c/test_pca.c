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

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <yael/vector.h>
#include <yael/matrix.h>


/* 
Copy/paste the points matrix into octave and compare:

[d,n]=size(centered_v)

cov=centered_v * centered_v';

[cov_eigenvectors,cov_eigenvalues]=eig(cov);

cov_eigenvalues=diag(cov_eigenvalues);

[sorted,perm]=sort(cov_eigenvalues)
cov_eigenvectors(:,perm(end:-1:1))

Lines should be the same up to the sign as eigs_f output


*/


void test_std (long n, long d, float *v) 
{
  fmat_center_columns(d,n,v);

  printf("\ncentered_v=");
  fmat_print(v,d,n);

  float *eig_f=fmat_new_pca(d,n,v,NULL);  
  
  printf("\neig_f=");
  fmat_print(eig_f,d,d);
  free(eig_f);
}



#define PCA_BLOCK_SIZE 256



pca_online_t * pca_online (long n, int d, const float *v)
{
  long i;

  pca_online_t * pca = pca_online_new (d);

  for (i = 0 ; i < n ; i += PCA_BLOCK_SIZE) {
    long iend = i + PCA_BLOCK_SIZE;
    if (iend > n) iend = n;
    long ntmp = iend - i;
    const float * vb = v + i * d;

    pca_online_accu (pca, vb, ntmp);
  }

  /* compute the PCA decomposition itself */
  pca_online_complete (pca);

  return pca;
}



/* Apply the matrix multiplication by block */
void apply_pca (const struct pca_online_s * pca, float * v, float * vo, int d, int n, int dout)
{
  long i;

  for (i = 0 ; i < n ; i += PCA_BLOCK_SIZE) {
    long iend = i + PCA_BLOCK_SIZE;
    if (iend > n) iend = n;
    long ntmp = iend - i;

    pca_online_project (pca, v + i * d, vo + i * dout, d, ntmp, dout);
  }  

  printf("\ncentered_v=");
  fmat_center_columns(d,n,v);
  fmat_print(v,d,n);

  double energy_in = fvec_sum_sqr (v, n * d);
  double energy_out = fvec_sum_sqr (vo, n * dout);
  printf ("Energy preserved = %.3f\n", (float) (energy_out / energy_in));
}



int main (int argc, char **argv)
{
  int d, n;

  if(argc!=3 || sscanf(argv[1],"%d",&n)!=1 || sscanf(argv[2],"%d",&d)!=1) {
    fprintf(stderr,"usage: test_pca npt ndim\n");
    return 1;
  }

  long i;
  float *v = fvec_new(n*d);
  for (i=0;i<n*d;i++) 
    v[i]=drand48()*2-1;
  float * v1 = fvec_new_cpy (v, n*d);

  /* reference version */
  test_std(n, d, v1);

  /* version with on-line reading of vectors */
  pca_online_t * pca = pca_online(n, d, v);
  
  printf("\ncov2=");
  fmat_print(pca->cov,d,d);

  printf("\neigvec=");
  fmat_print(pca->eigvec,d,d);


  /* Project the vector using the PCA matrix */
  int dout = d;
  float * vo = fvec_new (n*d);
  apply_pca (pca, v, vo, d, n, dout);

  free(v);

  return 0;
}

