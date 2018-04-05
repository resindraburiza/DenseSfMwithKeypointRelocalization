from yael import yael
import time

n = 20000                         # number of vectors
nq = 1000 
d = 128                           # dimensionality of the vectors
nt = 2                            # number of threads to use
k = 1                             # number of nn returned

v = yael.fvec_new_rand (d * n)    # random set of vectors 
q = yael.fvec_new_rand (d * nq)

idx = yael.ivec_new (nq * k)
dis = yael.fvec_new (nq * k)


t1 = time.time()
yael.knn_thread (nq, n, d, k, v, q, idx, nt)
t2 = time.time()

idx = yael.IntArray.acquirepointer (idx)

print [idx[i] for i in xrange (nq * k)]

print 'kmeans performed in %.3fs' % (t2 - t1)
