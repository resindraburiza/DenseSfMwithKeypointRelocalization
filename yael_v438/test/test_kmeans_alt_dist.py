
import time

from yael import yael

yael.common_srandom(12345)

d=16
n=1024
k=4

pts = yael.fvec_new_rand(d * n)

pts = yael.fvec.acquirepointer(pts)

cents = yael.fvec(d * k)

nt = 1
assign = yael.ivec(n)
  

def d_chi2(a, b):
  return (a - b) ** 2 / (a + b)

print "clustering %d uniform %dD pts in %d centroids" % (n, d, k) 

for name, flags in ("L2", 0), ("L1", yael.KMEANS_L1), ("Chi2", yael.KMEANS_CHI2):
  print "%s clustering" % name 

  t0 = time.time()
  
  flags |= nt | yael.KMEANS_QUIET

  for run in range(10): 

    final_err = yael.kmeans(d, n, k, 35, pts, flags, 12345+run, 10, cents, None, assign, None)

    # yael.fmat_print(cents, d, k)


    print "run %3d L1 err = %g" % (run, sum([abs(cents[assign[i]*d + j] - pts[i*d+j])
                                      for i in range(n) for j in range(d)]))

    print "run %3d Chi2 err = %g" % (run, sum([d_chi2(cents[assign[i]*d + j], pts[i*d+j])
                                      for i in range(n) for j in range(d)]))

  print "time: %.3f s" % (time.time() - t0) 
