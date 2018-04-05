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
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <yael/machinedeps.h>
#include <yael/vector.h>
#include <yael/eigs.h>
#include <yael/matrix.h>

/* 
executed on node40
export LD_LIBRARY_PATH=../../yael/:/home/clear/lear/intel/mkl/lib/intel64/

gcc -Wall -o loop_pca_size loop_pca_size.c -g -I../.. -L ../../yael -lyael -DFINTEGER=long -L/home/clear/lear/intel/mkl/lib/intel64/ -lmkl_intel_ilp64 && ./loop_pca_size 

*/

void print_some_eigs(long d, long nev, const float *eigval, const float *eigvec) {
  printf("eigenvals = ["); 
  int i; 
  for(i = 0; i < nev && i < 10; i++) printf("%g ", eigval[i]); 
  
  printf("]\nvecs=["); 
  
  for(i = 0; i < d && i < 10; i++) {
    int j; 
    for(j = 0; j < nev && j < 10; j++)       
      printf("%9.6f ", eigvec[i + j * d]);
    if(j < nev) printf("...\n      "); 
    else printf("\n      "); 
  } 
  printf("]\n"); 
}


double sqr(double x) {return x*x; } 

#define real float
#define integer FINTEGER

int ssyevx_(char *jobz, char *range, char *uplo, integer *n, 
        real *a, integer *lda, real *vl, real *vu, integer *il, integer *iu, 
        real *abstol, integer *m, real *w, real *z__, integer *ldz, real *
            work, integer *lwork, integer *iwork, integer *ifail, integer *info);

#undef real 
#undef integer




int main(int argc, char** argv) {
/*
  long d = 64 * 64; 
  long nblock = 40, blocksize = 1000; 

  long d = 64 * 256;
  long nblock = 160, blocksize = 1000; 

*/
  long d = 65536;
  long nblock = 88, blocksize = 1000; 
  

  long n = nblock * blocksize; 
    
  float *x = fvec_new(n * d); 

  long i; 
  setvbuf(stdout, NULL, _IONBF, 0);

  if(d == 65536) {
    const char *fname = "/tmp/buf_64kD.fvecs"; 
    fvecs_read(fname, d, n, x);     
    
    long nnan = fvec_purge_nans(x, n, 0); 
    printf("  purged %d nans\n", nnan);
  } else {
  
    for(i = 0; i < nblock; i++) {
      char fname[1024]; 
      switch(d) {
      case 16384:
        sprintf(fname, "/scratch2/bigimbaz/dataset/flickr//smalldesc/fisher/ff_k256_%02d.fvecs", i); 
        break;
      case 4096:
        sprintf(fname, "/scratch2/bigimbaz/dataset/flickr//smalldesc/fisher/ff_k64_%02d.fvecs", i); 
        break;
      default: assert(0); 
      }
      printf("loading block %d %s\n", i, fname); 
      fvecs_read(fname, d, blocksize, x + i * blocksize * d);     
      
      long nnan = fvec_purge_nans(x + i * blocksize * d, blocksize * d, 0); 
      printf("  purged %d nans\n", nnan);
    }
  }
  
  printf("loaded %ld pts in %ld dimensions\n", n, d);
  

  pca_online_t * pca_online = pca_online_new (d); 
  
  {
    printf("computing covariance matrix\n"); 
    double t0 = getmillisecs(); 
    
    for(i = 0; i < nblock; i++) {
      printf("block %d\n", i); 
      pca_online_accu(pca_online, x + i * blocksize * d, blocksize);
    }

    pca_online_cov(pca_online);
    
    printf("covariance time: %.3f ms\n", getmillisecs() - t0); 
  }

  {
    double t0 = getmillisecs(); 
    
    printf("subtracting mean from data\n"); 
    fmat_subtract_from_columns (d, n, x, pca_online->mu);

    printf("subtract mean time: %.3f ms\n", getmillisecs() - t0); 
  }
#if 0
  {
    printf("computing full eigenvals / vecs\n"); 
    
    double t1 = getmillisecs(); 
    
    pca_online_complete(pca_online); 
    
    printf("full time: %.3f ms\n", getmillisecs() - t1); 
    
    print_some_eigs(d, d, pca_online->eigval, pca_online->eigvec); 
  }
#endif
  
  {
    int nev; 

    for(nev = 1; nev < d / 2; nev *= 2) {

      {
        memset(pca_online->eigval, -1, sizeof(*pca_online->eigval) * d); 
        memset(pca_online->eigvec, -1, sizeof(*pca_online->eigvec) * d * d); 
        
        printf("Arpack partial PCA %d evs (on-the-fly matrix-vec multiply):\n", nev); 
        
        double t1 = getmillisecs();       
        
        fmat_svd_partial_full(d, n, nev, x, 0, pca_online->eigval, pca_online->eigvec, NULL, 1); 
        
        for(i = 0; i < nev; i++) pca_online->eigval[i] = sqr(pca_online->eigval[i]) / (n - 1);           

        printf("on-the-fly %d time: %.3f ms\n", nev, getmillisecs() - t1); 
        
        print_some_eigs(d, nev, pca_online->eigval, pca_online->eigvec);        
        
      }

      {
        memset(pca_online->eigval, -1, sizeof(*pca_online->eigval) * d); 
        memset(pca_online->eigvec, -1, sizeof(*pca_online->eigvec) * d * d);      
        printf("Arpack partial PCA %d evs (from covariance matrix):\n", nev); 

        double t1 = getmillisecs(); 
        
        pca_online_complete_part(pca_online, nev); 
        
        printf("cov %d time: %.3f ms\n", nev, getmillisecs() - t1); 
        
        print_some_eigs(d, nev, pca_online->eigval, pca_online->eigvec);       
      }

      {
        memset(pca_online->eigval, -1, sizeof(*pca_online->eigval) * d); 
        memset(pca_online->eigvec, -1, sizeof(*pca_online->eigvec) * d * d);      
        printf("ssyevx partial PCA %d evs (from covariance matrix):\n", nev); 

        double t1 = getmillisecs(); 
        

        {
          /* tri-diagonalize cov matrix */
          float *a = fvec_new(d * d); 

          fvec_cpy(a, pca_online->cov, d * d); 
          
          FINTEGER ni = d; 
          FINTEGER il = d - nev + 1, iu = d, m, nsplit; 
          float zero = 0; 
          FINTEGER info, lwork = -1; 
          float workq[1];           
          FINTEGER *iwork = malloc(sizeof(FINTEGER) * d * 5); 
          FINTEGER *ifail = malloc(sizeof(FINTEGER) * d); 

          ssyevx_("V", "I", "U", &ni, a, &ni, NULL, NULL, &il, &iu, &zero, 
                  &m, pca_online->eigval, pca_online->eigvec, &ni, 
                  workq, &lwork, iwork, ifail, &info); 

          assert(info == 0); 
          
          lwork = (long)workq[0]; 
          float *work = fvec_new(lwork); 
                   
          ssyevx_("V", "I", "U", &ni, a, &ni, NULL, NULL, &il, &iu, &zero, 
                  &m, pca_online->eigval, pca_online->eigvec, &ni, 
                  work, &lwork, iwork, ifail, &info); 

          /* reverse order of evs */ 
          fvec_revert(pca_online->eigval, nev); 
          for(i = 0; 2 * i < nev; i++) {
            fvec_swap(pca_online->eigvec + i * d, 
                      pca_online->eigvec + (nev - 1 - i) * d, 
                      d); 
          }          

          if(info != 0) {
            printf("  ssyevx info = %d\n", info); 
            abort();
          }

          free(ifail); free(iwork); free(a); 
                                              
        }

        printf("ssyevx %d time: %.3f ms\n", nev, getmillisecs() - t1); 
        
        print_some_eigs(d, nev, pca_online->eigval, pca_online->eigvec);       
      }

    }
    
    
  }
  

  
  return 0; 

}
