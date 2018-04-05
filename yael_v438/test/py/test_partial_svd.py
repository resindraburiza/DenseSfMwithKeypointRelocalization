





from yael.yael import *

d=4
n=6
ns=2

print "a="

a=FloatArray.acquirepointer(fvec_new_rand(d*n))

fmat_print(a,d,n)

s=FloatArray(ns)
u=FloatArray(ns*d)
v=FloatArray(ns*n)

fmat_svd_partial(d,n,ns,a,s,u,v)

print "singvecs="
fvec_print(s,ns)


print "u="
fmat_print(u,d,ns)

print "v="
fmat_print(v,n,ns)


print "test transposed version"

s=FloatArray(ns)
u=FloatArray(ns*d)
v=FloatArray(ns*n)

fmat_svd_partial_full(n,d,ns,a,1,s,v,u,4)

print "singvecs="
fvec_print(s,ns)

print "u="
fmat_print(u,d,ns)

print "v="
fmat_print(v,n,ns)


## (fpoints,n,d)=fvecs_new_read("/tmp/fpoints.fvecs")

## nev=150

## svs=FloatArray(nev)
## pcamat=fmat_new_pca_part(d,n,nev,fpoints,svs)
