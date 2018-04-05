

from yael import yael


m=3
n=4
k=5

a=yael.FloatArray.acquirepointer(yael.fvec_new_rand(m*k))
b=yael.FloatArray.acquirepointer(yael.fvec_new_rand(k*n))

for transp in ['NN','NT','TN','TT']: 

  print "=====================",transp

  print "a=",
  if transp[0]=='N': yael.fmat_print(a,m,k)
  else:              yael.fmat_print_tranposed(a,m,k)

  print "b=",
  if transp[1]=='N': yael.fmat_print(b,k,n)
  else:              yael.fmat_print_tranposed(b,k,n)

  res=yael.FloatArray.acquirepointer(yael.fmat_new_mul_full(a,b,m,n,k,transp))

  print "a*b=",
  yael.fmat_print(res,m,n)

