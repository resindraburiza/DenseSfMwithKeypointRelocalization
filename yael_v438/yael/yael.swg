// -*- c++ -*- 

%module yael;


/*****************************************************
 * a few useful functions & objects for everywhere:
 * - array objects 
 * - nearest neighbour and clustering functions
 */


%{

#include "nn.h"
#include "kmeans.h"
#include "hkm.h"
#include "sorting.h"
#include "binheap.h" 
#include "vector.h"
#include "matrix.h"
#include "eigs.h"
#include "gmm.h"
#include "vlad.h"
#include "machinedeps.h"
#include "kmlsh.h"
#include "ivf.h"

/* seed generators used in the rest */
void common_srandom(int seed) {
  srandom(seed);
  srand(seed);
  srand48(seed); 
}

typedef int * int_pointer_t;
typedef float * float_pointer_t;
typedef unsigned char * byte_pointer_t;

/* not available in Python */
double NaN = 0.0 / 0.0; 
double Inf = 1.0 / 0.0; 

/* for interfacing with ctypes */

float * fvec_from_pointer_long(long ptr) { return (float*)ptr; }
long fvec_to_pointer_long(float *fv) { return (long)fv; }

double * dvec_from_pointer_long(long ptr) { return (double*)ptr; }
long dvec_to_pointer_long(double *fv) { return (long)fv; }

%}

%include "common.swg"

extern double NaN, Inf;

float * fvec_from_pointer_long(long ptr);
long fvec_to_pointer_long(float *fv);

double * dvec_from_pointer_long(long ptr);
long dvec_to_pointer_long(double *fv);


array_class_plus(double,DoubleArray)
array_class_plus(float,FloatArray)
array_class_plus(int,IntArray)
array_class_plus(unsigned char,bvec)
array_class_plus(short, int16vec)
array_class_plus(unsigned short, uint16vec)
array_class_plus(long long,lvec)
array_class_plus(unsigned long long,UInt64Array)


%extend IntArray {
  IntArray(PyObject *list) {
    if(!PySequence_Check(list)) {
      PyErr_SetString(PyExc_TypeError,"need sequence as input");
      return NULL;
    }  
    long sz=PySequence_Size(list),i;
    int *ret=malloc(sizeof(int)*sz);
    for(i=0;i<sz;i++) {
      PyObject *li=PySequence_GetItem(list,i);
      if(!PyInt_Check(li))  {
        PyErr_SetString(PyExc_TypeError,"need ints in sequence");
        free(ret);
        return NULL;
      }  
      ret[i]=PyInt_AsLong(li);
    }
    return ret;
  }
}



%extend FloatArray {
  FloatArray(PyObject *list) {
    if(!PySequence_Check(list)) {
      PyErr_SetString(PyExc_TypeError,"need sequence as input");
      return NULL;
    }  
    long sz=PySequence_Size(list),i;
    float *ret=malloc(sizeof(float)*sz);
    for(i=0;i<sz;i++) {
      PyObject *li=PyList_GetItem(list,i);
      if(!PyFloat_Check(li))  {
        PyErr_SetString(PyExc_TypeError,"need floats in sequence");
        free(ret);
        return NULL;
      }  
      ret[i]=PyFloat_AsDouble(li);
    }
    return ret;
  }
}

typedef int * int_pointer_t;
typedef float * float_pointer_t;
typedef unsigned char * byte_pointer_t;

array_class_plus(int_pointer_t,IntPtrArray)
array_class_plus(float_pointer_t,FloatPtrArray)
array_class_plus(byte_pointer_t,BytePtrArray)

%pythoncode {

  fvec=FloatArray
  dvec=DoubleArray
  ivec=IntArray
}



/*************************************************************************
 * nn.h
 */

%exception {
  Py_BEGIN_ALLOW_THREADS
  $action
  Py_END_ALLOW_THREADS
}

// ?vecs_size functions returns a tuple (nbytes, n,d)
%typemap(in,numinputs=0) 
  (int *d_out,int *n_out)
  (int d,int n) {
  $1=&d;
  $2=&n;
}

%typemap(argout) (int *d_out,int *n_out)  {
  $result=Py_BuildValue
    ("(Nii)", $result, *$1,*$2);
}



// fvecs_new_read and fvecs_new_fread_max returns a tuple 
// (floats,n,d)
// floats= float table
// d=dimension of the pts (128)
// n=nb of vectors or -1 on error

%typemap(in,numinputs=0) 
  (int *d_out,float **vf)
  (int d,float *vf) {
  $1=&d;
  $2=&vf;
}

%typemap(argout) (int *d_out,float **vf)  {
  $result=Py_BuildValue
        ("(NNi)",
         SWIG_NewPointerObj(*$2,SWIGTYPE_p_float,0),
         $result,*$1);
}


// // bvecs_new_read returns a tuple 
// // (bts,n,d)

// %typemap(in,numinputs=0) 
//   (int *d_out,unsigned char **vb)
//   (int d,unsigned char *vb) {
//   $1=&d;
//   $2=&vi;
// }

// %typemap(argout) (int *d_out,unsigned char **vb)  {
//   $result=Py_BuildValue
//         ("(NNi)",
//          SWIG_NewPointerObj(*$2,SWIGTYPE_p_byte,0),
//          $result,*$1);
// } 



// ivecs_new_read returns a tuple 
// (ints,n,d)
// ints= float table
// d=dimension of the pts (128)
// n=nb of centroids or -1 on error

%typemap(in,numinputs=0) 
  (int *d_out,int **vi)
  (int d,int *vi) {
  $1=&d;
  $2=&vi;
}

%typemap(argout) (int *d_out,int **vi)  {
  $result=Py_BuildValue
        ("(NNi)",
         SWIG_NewPointerObj(*$2,SWIGTYPE_p_int,0),
         $result,*$1);
}

// for ivec_new_read

%typemap(in,numinputs=0) 
  (int *d_out)
  (int d) {
  $1=&d;
}

%typemap(argout) (int *d_out)  {
  $result=Py_BuildValue
        ("(Ni)",
         $result,*$1);
}



// slow functions 
PARALLEL_FUNCTION(nn)
PARALLEL_FUNCTION(knn)
PARALLEL_FUNCTION(knn_thread)
PARALLEL_FUNCTION(nn_thread)

PARALLEL_FUNCTION(knn_full)
PARALLEL_FUNCTION(knn_full_thread)




%include "nn.h"


/*************************************************************************
 * kmeans.h
 */


// wrap clustering_kmeans_assign to return (clust_assign,*cluster_size)
%typemap(in,numinputs=0)
        (int ** clust_assign_out) 
  (int *clust_assign) {
  $1=&clust_assign;
}

%typemap(argout) (int ** clust_assign_out)  {
  $result=Py_BuildValue
        ("(NN)",
         $result,
        SWIG_NewPointerObj(*$1,SWIGTYPE_p_int,0));
}



%include "kmeans.h"

%include "hkm.h"

/*************************************************************************
 * sorting.h
 */

%typemap(in,numinputs=0)
        (int **labels_out,float **vals_out) 
  (int *labels,float *vals) {
  $1=&labels;
  $2=&vals;
}

%typemap(argout) (int **labels_out,float **vals_out) {
  $result=Py_BuildValue
        ("(NNN)",
         $result,
         SWIG_NewPointerObj(*$1,SWIGTYPE_p_int,0),
         SWIG_NewPointerObj(*$2,SWIGTYPE_p_float,0));
}




%include "sorting.h"


/*************************************************************************
 * binheap.h
 */

%include "binheap.h" 


/*************************************************************************
 * vector.h
 */


%typemap(in,numinputs=0) 
  (int ** idx_out, float ** v_out)
  (int *idx,float *v) {
  $1=&idx;
  $2=&v;
}

%typemap(argout) (int ** idx_out, float ** v_out)  {
  $result=Py_BuildValue
        ("(NNN)",
         $result,
         SWIG_NewPointerObj(*$1,SWIGTYPE_p_int,0),
         SWIG_NewPointerObj(*$2,SWIGTYPE_p_float,0));
}


%typemap(in,numinputs=0) 
  (float ** vf_out)
  (float *vf) {
  $1=&vf;
}

%typemap(argout) (float ** vf_out)  {
  $result=Py_BuildValue
        ("(NN)",
         $result,
         SWIG_NewPointerObj(*$1,SWIGTYPE_p_float,0));
}




%include "vector.h"



/*************************************************************************
 * matrix.h
 */


%include "matrix.h"

%typemap(in,numinputs=0) 
  (float **x_out, float **y_out)
  (float *x,float *y) {
  $1=&x;
  $2=&y;
}

%typemap(argout) (float **x_out, float **y_out) {
  $result=Py_BuildValue
        ("(NNN)",
         $result,
         SWIG_NewPointerObj(*$1,SWIGTYPE_p_float,0),
         SWIG_NewPointerObj(*$2,SWIGTYPE_p_float,0));
}


%include "eigs.h"


/*************************************************************************
 * gmm.h
 */


%include "gmm.h"


%include "vlad.h"


/*************************************************************************
 * kmlsh.h
 */

%include "kmlsh.h"

/*************************************************************************
 * ivf.h
 */

%typemap(in,noblock=1) int * buffer_size  {
  int bufsize;
  bufsize = $input;
  $1 = &bufsize;
}

%typemap(out) ivfmatch_t* ivf_hequery {
  int i;
  npy_intp shp[2];
  shp[0] = bufsize;
  shp[1] = 3;
  $result = PyArray_SimpleNew(2, shp, NPY_INT32);
  int *dest = PyArray_DATA($result);
  for (i = 0; i < bufsize; i++) {
    dest[i * 3    ] = $1[i].qid;
    dest[i * 3 + 1] = $1[i].bid;
    dest[i * 3 + 2] = (int)$1[i].score;
  }
  free($1);
}

#ifdef HAVE_NUMPY
%ignore ivf_he_count_crossmatches2;
%ignore ivf_he_crossmatches_prealloc2;
%ignore ivf_he_collect_crossmatches2;

%include "ivf.h"
#endif

/*************************************************************************
 * allows freeing some elements allocated by malloc/calloc in python
 */
void free (void *);


%include "machinedeps.h"

void common_srandom(int seed);


void free(void*);



/*************************************************************************
 * Numpy wrapper 
 */

%define NUMPY_EXCHANGE(xvec, ctype, numpytype)

%{

// declare in C

PyObject * xvec ## _to_numpy(const ctype *src, int ndim, npy_intp shp[]) {
  int i, totsize;
  PyObject* ob = PyArray_SimpleNew(ndim, shp, numpytype);
  ctype *dest = PyArray_DATA(ob);
  totsize = (int)shp[0];
  for (i=1; i<ndim; i++)
    totsize *= (int)shp[i];
  memcpy(dest, src, sizeof(ctype) * totsize);
  return ob;
}

PyObject * xvec ## _to_numpy_ref(ctype *src, int ndim, npy_intp shp[]) {
  return PyArray_SimpleNewFromData(ndim, shp, numpytype, src);
}

PyObject * xvec ## _to_numpy_acquire(ctype *src, int ndim, npy_intp shp[]) {
  PyObject * ret = PyArray_SimpleNewFromData(ndim, shp, numpytype, src);
  ((PyArrayObject*)ret)->flags |= NPY_OWNDATA;
  return ret;
}


ctype *numpy_to_ ## xvec(long di, ctype *data) {
  size_t sz = di * sizeof(ctype);
  void *ret = malloc(sz);
  memcpy(ret, data, sz);
  return ret;
}

ctype *numpy_to_ ## xvec ## _ref(long di, ctype *data) {
  return data;
}

%}



// re-declare for SWIG

%typemap(in) (int ndim, npy_intp shp[])(int _ndim, int _shp[8], npy_intp __shp[8]) {
  if (PyTuple_Check($input)) {
    _ndim = PyTuple_Size($input);
    if (_ndim > 8) {
      PyErr_SetString(PyExc_TypeError,"Invalid shape. Expecting tuple size <=8.");
      return NULL;
    }
    if (!PyArg_ParseTuple($input, "i|iiiiiii", _shp, _shp+1, _shp+2, _shp+3, _shp+4, _shp+5, _shp+6, _shp+7)) {
      PyErr_SetString(PyExc_TypeError,"Invalid shape. Expecting tuple of int.");
      return NULL;
    }
  } else if(PyInt_Check($input)) {
    _ndim = 1;
    _shp[0] = PyInt_AsLong($input);
  } else {
    PyErr_SetString(PyExc_TypeError,"Invalid shape. Expected tuple or int.");
    return NULL;
  }
  $1 = _ndim;
  int i;
  for (i=0; i<_ndim; i++)
    __shp[i] = _shp[i];
  $2 = __shp;
}
%feature("autodoc", "xvec _to_numpy(src, shape) -> numpy.ndarray\n\
 shape can be an integer or a tuple of integers (maximum 8 dimentions)\n\
 Creates a new ndarray of specified shape with a copy xvec data.") xvec ## _to_numpy;
PyObject * xvec ## _to_numpy(const ctype *src, int ndim, npy_intp shp[]);

%feature("autodoc", "xvec _to_numpy(src, shape) -> numpy.ndarray\n\
 shape can be an integer or a tuple of integers (maximum 8 dimentions)\n\
 Creates a new ndarray of specified shape pointing to xvec data\n\
 *without taking ownership of the memory* (you will have to free it manually).") xvec ## _to_numpy_ref;
 
PyObject * xvec ## _to_numpy_ref(ctype *src, int ndim, npy_intp shp[]);
%feature("autodoc", "xvec _to_numpy(src, shape) -> numpy.ndarray\n\
 shape can be an integer or a tuple of integers (maximum 8 dimentions)\n\
 Creates a new ndarray of specified shape pointing to xvec data and \n\
 *takes ownership of the memory* (it will be freed by the GC when the ndarray isn't referenced anymore).") xvec ## _to_numpy_acquire;
PyObject * xvec ## _to_numpy_acquire(ctype *src, int ndim, npy_intp shp[]);

%typemap(in, numinputs=1) (long di, ctype *data) {
  if(!PyArray_Check($input)) {
    PyErr_SetString(PyExc_ValueError, "input not a numpy array");
    return NULL;
  }
  if(PyArray_TYPE($input) != numpytype) {
    PyErr_SetString(PyExc_ValueError, "array has bad type");
    return NULL;
  }
  
  if(!PyArray_ISCONTIGUOUS($input)) {
    PyErr_SetString(PyExc_ValueError, "array is not C-contiguous");
    return NULL;
  }
  $1 = PyArray_SIZE($input);
  $2 = PyArray_DATA($input);
}

ctype *numpy_to_ ## xvec(long di, ctype *data);
ctype *numpy_to_ ## xvec ## _ref(long di, ctype *data);

%typemap(in, numinputs=1) (long di, ctype *data);

%enddef




#ifdef HAVE_NUMPY


%{
#define SWIG_FILE_WITH_INIT

#include <numpy/arrayobject.h>

%}


%init %{
/* needed, else crash at runtime */
    import_array();
%}



NUMPY_EXCHANGE(bvec, unsigned char, NPY_UINT8);
NUMPY_EXCHANGE(fvec, float, NPY_FLOAT32);
NUMPY_EXCHANGE(ivec, int, NPY_INT32);
NUMPY_EXCHANGE(int16vec, short, NPY_INT16);
NUMPY_EXCHANGE(uint16vec, unsigned short, NPY_UINT16);
NUMPY_EXCHANGE(dvec, double, NPY_FLOAT64);


#endif
