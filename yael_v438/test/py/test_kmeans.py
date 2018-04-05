from yael import yael
import time

k = 100                           # number of cluster to create
d = 128                           # dimensionality of the vectors
n = 10000                        # number of vectors
nt = 10                            # number of threads to use
v = yael.fvec_new_rand (d * n)    # random set of vectors 
niter = 30                        # number of iterations
redo = 1                          # number of redo

#[centroids, dis, assign] = yael_kmeans (v, 100, 'nt', 2, 'niter', 25);

centroids = yael.fvec_new (d * k) # output: centroids
dis = yael.fvec_new (n)           # point-to-cluster distance
assign = yael.ivec_new (n)        # quantization index of each point
nassign = yael.ivec_new (k)       # output: number of vectors assigned to each centroid

nassign = yael.IntArray.acquirepointer (nassign)

t1 = time.time()
yael.kmeans (d, n, k, niter, v, nt, 0, redo, centroids, dis, assign, nassign)
t2 = time.time()

print [nassign[i] for i in xrange(k)]
print 'kmeans performed in %.3fs' % (t2 - t1)
