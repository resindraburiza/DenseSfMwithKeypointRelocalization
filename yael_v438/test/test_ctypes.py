"""

Experiments on sharing arrays between Yael and ctypes. The interface
datatype is C's long.

The functions here are for fvec, but adding a few functions in yael.swg
should make it run with ivec, dvec, etc. as well.

"""


from yael import yael

import ctypes



print "ctypes -> Yael"

print "  init in ctypes"

ctypes_fvec_150_t = ctypes.c_float * 150

ctypes_fvec = ctypes_fvec_150_t()

ctypes_fvec[0] = 1001 
ctypes_fvec[1] = 1002

print "  read in Yael:",

yael_fvec = yael.fvec_from_pointer_long(ctypes.addressof(ctypes_fvec))
yael_fvec = yael.fvec.frompointer(yael_fvec)

print yael_fvec[0], yael_fvec[1]

print "Yael -> ctypes"

print "  init in Yael"

yael_fvec = yael.fvec(30)

yael_fvec[0] = 2001
yael_fvec[1] = 2002


print "  read in ctypes",

ctypes_fvec_t = ctypes.POINTER(ctypes.c_float)
ctypes_fvec = ctypes.cast(yael.fvec_to_pointer_long(yael_fvec), ctypes_fvec_t)

print ctypes_fvec[0], ctypes_fvec[1]

