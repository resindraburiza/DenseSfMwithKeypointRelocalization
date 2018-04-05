
import sys

from yael.yael import *

from numpy import array

print "Testing Yael <-> numpy interface"

if "fvec_to_numpy" not in globals():
  print "Numpy interface not compiled in"
  sys.exit(1)

print "float array"

numpy_a=array(range(5),dtype='float32')

print numpy_a

print "-> Yael"

yael_a=FloatArray.acquirepointer(numpy_to_fvec(numpy_a))
n=numpy_a.size

fvec_print(yael_a,n)

print "-> Numpy"

print fvec_to_numpy(yael_a,n)

print "int array"

numpy_a=array(range(5),dtype='int32')

print numpy_a

print "-> Yael"

yael_a=IntArray.acquirepointer(numpy_to_ivec(numpy_a))
n=numpy_a.size

ivec_print(yael_a,n)

print "-> Numpy"

print ivec_to_numpy(yael_a,n)

print "float array, pass by reference"


numpy_a=array(range(5),dtype='float32')

print numpy_a

yael_a=FloatArray.acquirepointer(numpy_to_fvec_ref(numpy_a))
n=numpy_a.size

fvec_print(yael_a,n)

del numpy_a

print "Crash!"

fvec_print(yael_a,n)
