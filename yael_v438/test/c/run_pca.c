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


/* sample test:
   export OMP_NUM_THREADS=16
   ./run_pca cov -fi test.dat -favg test.avg -fcov test.cov -n 10 -d 4 
   ./run_pca eig -fcov test.cov -fevec test.evec -feval test.eval -d 4 -dout 2
   ./run_pca apply -favg test.avg -n 10 -d 4 -dout 2 -fevec test.evec -feval test.eval -fi test.dat -fo test.out

To check in Matlab that this gives the same results:

  f=fopen('test','r');
  a=fread(f,'single');
  n=10;a=reshape(a,4,n);
  fclose(f);
  mu=mean(a,2);
  ac=a-repmat(mu,1,n);
  cv=ac*ac'/(n-1);     % Covariance matrix

  [cov_eigenvectors,cov_eigenvalues]=eig(cv);
  cov_eigenvalues=diag(cov_eigenvalues);
  [sorted,perm]=sort(cov_eigenvalues, 'descend')
  cov_eigenvectors(:,perm)
*/   

void usage (const char * cmd)
{
  printf ("Usage: %s cov|eig|apply [-v] -n # -d # -fi fi [-fcov fcov] [-favg favg]\n"
	  "          [-fevec fevec] [-feval feval] [-fo fvout]\n\n", cmd);
  printf ("Output: all output file are optional (produced only if option is specified)\n"
	  "  Parameters (in brackets: corresponding action)\n"
	  "    cov|eig|apply     first argument is the action to be performed\n"
          "                      cov     compute the covariance matrix\n"
          "                      eig     compute the eigendecomposition of the covariance matrix\n"
          "                      apply   apply the PCA rotation to the input file\n"
	  "    -v                verbose output\n"
	  "    -n #              number of vectors\n"
          "    -d #              dimension of the vectors\n"
          "    -dout #           dimension of the output vectors\n"
          "    -plaw #           [apply] pre-process vector using sqrt component-wise normalization\n"
          "    -norm #           [apply] pre-normalization of input vector (may be after powerlaw)\n\n"
	  "   Following files are input or output, depending the step (cov|eig|apply)\n"
          "   All these files are in raw format (float32)               |output|input\n"              
	  "    -fi filename      file of input vectors (raw format)     |      |cov,apply\n"
	  "    -favg filename    raw file: mean values                  |  cov |apply\n"
	  "    -fcov filename    raw file: covariance matrix (sym)      |  cov |eig\n"
	  "    -fevec filename   raw file: eigenvectors                 |  eig |apply\n"
	  "    -feval filename   raw file: eigenvalues                  |  eig |apply\n"
	  "    -fo filename      file of PCA-transformed output vectors | apply|\n"
	  );
  exit (0);
}

/*---------------------------------*/
/* I/O                             */
/*---------------------------------*/

/* write output file in raw file format */
void write_raw_floats (const char * fname, const float * v, long n)
{
  int ret;
  FILE * f = fopen (fname, "w");
  if (!f) { 
    fprintf (stderr, "Unable to open file %s for writing\n", fname);
    exit (1);
  }

  ret = fwrite (v, sizeof (*v), n, f);
  if (ret != n) {
    fprintf (stderr, "Unable to write %ld floats in file %s\n", n, fname);
    exit (2);
  }
  fclose (f);
}

/* read input file in raw file format */
void write_read_floats (const char * fname, float * v, long n)
{
  int ret;
  FILE * f = fopen (fname, "r");
  if (!f) { 
    fprintf (stderr, "Unable to open file %s\n", fname);
    exit (1);
  }

  ret = fread (v, sizeof (*v), n, f);
  if (ret != n) {
    fprintf (stderr, "Unable to read %ld floats in file %s\n", n, fname);
    exit (2);
  }
  fclose (f);
}

/* To write the covariance matrix in a compact form */
void read_sym_matrix (const char * fname, float * v, long d)
{
  int ret;
  long i, j;
  FILE * f = fopen (fname, "r");
  if (!f) { 
    fprintf (stderr, "Unable to open file %s\n", fname);
    exit (1);
  }

  for (i = 0 ; i < d ; i++) {
    ret = fread (v + i * d, sizeof (*v), i+1, f);
    if (ret != i+1) {
      fprintf (stderr, "Error read_sym_matrix: Unable to read %ld floats in file %s\n", i+1, fname);
      exit (2);
    }
  }

  for (i = 0 ; i < d ; i++)
    for (j = 0 ; j < i ; j++)
      v[j * d + i] = v[i * d + j];
  fclose (f);
}


/* To read the compacted covariance matrix */
void write_sym_matrix (const char * fname, const float * v, long d)
{
  int ret;
  long i;
  FILE * f = fopen (fname, "w");
  if (!f) { 
    fprintf (stderr, "Unable to open file %s\n", fname);
    exit (1);
  }

  for (i = 0 ; i < d ; i++) {
    ret = fwrite (v + i * d, sizeof (*v), i+1, f);
    if (ret != i+1) {
      fprintf (stderr, "Error write_sym_matrix: Unable to read %ld floats in file %s\n", i+1, fname);
      exit (2);
    }
  }
  fclose (f);
}


/*---------------------------------*/
/* Various processing              */
/*---------------------------------*/


/* Pre-processing */
void preprocess (float * v, int d, long n, float plaw, float norm)
{
  /* Pre-processing: power-law on components */
  if (plaw >= 0) {
     fvec_spow (v, n * d, plaw);
  }
  
  /* Pre-processing: normalization */
  if (norm >= 0) {
    fvecs_normalize (v, n, d, norm);
    fvec_purge_nans (v, n * d, 0);
  }
}


/*---------------------------------*/
/* Online PCA                      */
/*---------------------------------*/


/* Online PCA -> accumulating covariance matrice on-the-fly, using blocks of data */
#define PCA_BLOCK_SIZE 256

pca_online_t * pca_cov (long n, int d, const char * fname, float plaw, float norm)
{
  long i;

  FILE * f = fopen (fname, "r");
  if (!f) { 
    fprintf (stderr, "Unable to open file %s for reading\n", fname);
    exit (1);
  }

  printf ("* PCA: accumulate mean and covariance matrix\n");

  pca_online_t * pca = pca_online_new (d);
  float * vbuf = fvec_new (PCA_BLOCK_SIZE * d);

  for (i = 0 ; i < n ; i += PCA_BLOCK_SIZE) {
    long iend = i + PCA_BLOCK_SIZE;
    if (iend > n) iend = n;
    long ntmp = iend - i;

    int ret = fread (vbuf, sizeof (*vbuf), ntmp * d, f);
    if (ret != ntmp * d) {
      fprintf (stderr, "Unable to read %ld floats in file %s\n", n, fname);
      exit (2);
    }
    preprocess (vbuf, d, ntmp, plaw, norm);
    pca_online_accu (pca, vbuf, ntmp);
  }

  pca_online_cov (pca);

  free (vbuf);
  fclose (f);
  return pca;
}

pca_online_t * pca_eigen (const char * cov_fname, int d, int dout)
{
  pca_online_t * pca = pca_online_new (d);
  read_sym_matrix (cov_fname, pca->cov, d);
  printf ("* PCA: perform the eigen-decomposition\n");

  pca_online_complete_part (pca, dout);
  return pca;
}

/* Apply the matrix multiplication by block */
void apply_pca (const struct pca_online_s * pca, 
		const char * finame, const char * foname, 
		int d, long n, int dout, float plaw, float norm)
{
  int ret;
  long i, ntmp = -1;

  FILE * fi = fopen (finame, "r");
  if (!fi) { 
    fprintf (stderr, "Unable to open file %s for reading\n", finame);
    exit (1);
  }

  FILE * fo = fopen (foname, "w");
  if (!fo) { 
    fprintf (stderr, "Unable to open file %s for writing\n", foname);
    exit (1);
  }

  float * vibuf = fvec_new (PCA_BLOCK_SIZE * d);
  float * vobuf = fvec_new (PCA_BLOCK_SIZE * dout);

  for (i = 0 ; i < n ; i += PCA_BLOCK_SIZE) {
    long iend = i + PCA_BLOCK_SIZE;
    if (iend > n) iend = n;
    ntmp = iend - i;
    
    ret = fread (vibuf, sizeof (*vibuf), ntmp * d, fi);

    if (ret != d * ntmp) {
      fprintf (stderr, "Unable to read %ld floats in file %s\n", n, finame);
      exit (2);
    }

    preprocess (vibuf, d, ntmp, plaw, norm);
    pca_online_project (pca, vibuf, vobuf, d, ntmp, dout);

    ret = fwrite (vobuf, sizeof (*vobuf), ntmp * dout, fo);
    if (ret != dout * ntmp) {
      fprintf (stderr, "Unable to write %ld floats in file %s\n", n, foname);
      exit (2);
    }
  }  

  fmat_center_columns (d, ntmp, vibuf);
  double energy_in = fvec_sum_sqr (vibuf, ntmp * d);
  double energy_out = fvec_sum_sqr (vobuf, ntmp * dout);
  printf ("Last block: Energy preserved = %.3f\n", (float) (energy_out / energy_in));

  free (vibuf);
  free (vobuf);
}



/*---------------------------------*/
/* Main                            */
/*---------------------------------*/

int main (int argc, char **argv)
{
  int i, ret;
  int verbose = 0;
  int d = -1;                        /* input dimensionality */
  int dout = -1;                     /* maximum output dimensionality */
  long n = -1;
  
  float plaw = -1;
  float norm = -1;

  const char * ivec_fname = NULL;    /* input vector file */
  const char * ovec_fname = NULL;    /* output vector file */
  const char * cov_fname = NULL;     /* file associated with covariance matrix */
  const char * avg_fname = NULL;     /* vector containing means */
  const char * evec_fname = NULL;    /* for Eigenvectors */
  const char * eval_fname = NULL;    /* for Eigenvalues */

  int action_cov = 0;                /* compute the covariance matrix */
  int action_eig = 0;                /* compute the PCA */
  int action_apply = 0;              /* apply the PCA to input file */

  /* First argument is the action to be performed */
  char *a = argv[1];

  if (argc < 2)
    usage (argv[0]);

  if (!strcmp (a, "cov"))
    action_cov = 1;
  else if (!strcmp (a, "eig"))
    action_eig = 1;
  else if (!strcmp (a, "apply"))
    action_apply = 1;
  else if (!strcmp (a, "-h") || !strcmp (a, "--help"))
    usage (argv[0]);
  else {
    fprintf (stderr, "Unknown action: %s\n\n", a);
    usage (argv[0]);
  }
  
  /* Other arguments */
  for (i = 2 ; i < argc ; i++) {
    a = argv[i];
    if (!strcmp (a, "-verbose") || !strcmp (a, "-v")) {
      verbose = 2;
    }
    else if (!strcmp (a, "-n") && i+1 < argc) {
      ret = sscanf (argv[++i], "%ld", &n);
      assert (ret);
    }
    else if (!strcmp (a, "-d") && i+1 < argc) {
      ret = sscanf (argv[++i], "%d", &d);
      assert (ret);
    }
    else if (!strcmp (a, "-dout") && i+1 < argc) {
      ret = sscanf (argv[++i], "%d", &dout);
      assert (ret);
    }
    else if (!strcmp (a, "-plaw") && i+1 < argc) {
      ret = sscanf (argv[++i], "%f", &plaw);
      assert (ret);
    }
    else if (!strcmp (a, "-norm") && i+1 < argc) {
      ret = sscanf (argv[++i], "%f", &norm);
      assert (ret);
    }
    //    else if (!strcmp (a, "-fb") && i+1 < argc)
    //***
    else if (!strcmp (a, "-fi") && i+1 < argc)
      ivec_fname = argv[++i];
    else if (!strcmp (a, "-fo") && i+1 < argc)
      ovec_fname = argv[++i];
    else if (!strcmp (a, "-fcov") && i+1 < argc)
      cov_fname = argv[++i];
    else if (!strcmp (a, "-favg") && i+1 < argc)
      avg_fname = argv[++i];
    else if (!strcmp (a, "-fevec") && i+1 < argc)
      evec_fname = argv[++i];
    else if (!strcmp (a, "-feval") && i+1 < argc)
      eval_fname = argv[++i];
    else {
      fprintf (stderr, "Unknown argument: %s\nAborting...\n", a);
      exit (4);
    }
  }

  if (d == -1)
    usage (argv[0]);

  /* By default, keep all dimensions */
  if (dout == -1)
    dout = d;

  if (verbose) {
    printf ("d=%d\nn=%ld\nvec=%s\ncov=%s\navg=%s\nevec=%s\neval=%s\novec=%s\n",
	    d, n, ivec_fname, cov_fname, avg_fname, evec_fname, eval_fname, ovec_fname);
  }

  /*--- Action: compute the covariance matrix ---*/
  if (action_cov) {
    if (n < 0) usage (argv[0]);
    if (!ivec_fname) usage(argv[0]);
    if (!cov_fname) usage(argv[0]);
    if (!avg_fname) usage(argv[0]);
    printf ("Covariance matrix stored in %s\n", cov_fname);

    /* Learning the covariance matrix */
    pca_online_t * pca = pca_cov (n, d, ivec_fname, plaw, norm);

    if (verbose) {
      printf ("mu=");    fvec_print (pca->mu,d);
      printf ("\ncov=\n"); fmat_print (pca->cov,d,dout);
    }

    /* write means and covariance matrix */
    write_sym_matrix (cov_fname, pca->cov, d);
    write_raw_floats (avg_fname, pca->mu, d);

    pca_online_delete (pca);
  }


  /*--- Action: Eigen-decomposition ---*/
  if (action_eig) {
    if (!cov_fname || !eval_fname || !evec_fname) usage(argv[0]);

    /* perform the eigen-decomposition: for the moment, slow method */	
    pca_online_t * pca = pca_eigen (cov_fname, d, dout);

    if (verbose) {
      printf ("eigenval = ");
      fvec_print (pca->eigval, d);
      fmat_print (pca->eigvec, d, dout);
    }

    /* write down the entities associated with eigen-decomposition */  
    write_raw_floats (eval_fname, pca->eigval, dout);
    write_raw_floats (evec_fname, pca->eigvec, d*dout);

    pca_online_delete (pca);
  }

  /*--- Action: apply the PCA ---*/
  if (action_apply) {
    pca_online_t * pca = pca_online_new (d);

    if (!ivec_fname) usage(argv[0]);
    if (!avg_fname) usage(argv[0]);
    if (!eval_fname) usage(argv[0]);
    if (!evec_fname) usage(argv[0]);

    FILE * favg = fopen (avg_fname, "r");    assert (favg);
    FILE * feval = fopen (eval_fname, "r");  assert (feval);
    FILE * fevec = fopen (evec_fname, "r");  assert (fevec);

    fvec_fread_raw (favg, pca->mu, d);
    fvec_fread_raw (feval, pca->eigval, dout);
    fvec_fread_raw (fevec, pca->eigvec, d*dout);
    fclose (favg);
    fclose (feval);
    fclose (fevec);

    apply_pca (pca, ivec_fname, ovec_fname, d, n, dout, plaw, norm);    
    pca_online_delete (pca);
  }

  return 0;
}
