import pdb
import numpy 
from yael import ynumpy


print "test knn"

d = 4
n = 5
nq = 3
nnn = 2

base = numpy.array([range(i, i+d) for i in range(5)], 
                   dtype = numpy.float32)

queries = numpy.array([[x + 0.25 for x in range(i, i+d)]
                       for i in range(nq)], 
                      dtype = numpy.float32)

print "base="
print base

print "queries="
print queries

idx, dis = ynumpy.knn(base, queries, nnn, distance_type = 1)

print "indices="
print idx 

print "distances="
print dis


try: 
    # v, meta = ynumpy.siftgeo_read('/Users/matthijs//Desktop/papers/lhl/trunk/data/test_query_10k.siftgeo')

    # v, meta = ynumpy.siftgeo_read('/scratch2/bigimbaz/dataset/holidays/siftgeo/hesaff_norm/128300.siftgeo')
    v, meta = ynumpy.siftgeo_read('/tmp/128300.siftgeo')
    v = v.astype('float32')
    
except Exception, e: 
    print e
    print "generating random data"
    v = numpy.random.normal(0, 1, size = (20, 4)).astype(numpy.float32)
    
    v[10:,:] += numpy.tile(numpy.random.uniform(-10, 10, size = (1, 4)),
                           (10, 1))
    
else: 
    print "vectors = "
    print v
    print "meta info = "
    print meta


print "kmeans:"

centroids = ynumpy.kmeans(v, 3)

print "result centroids ="
print centroids[:10,:]

print "gmm:"

gmm = ynumpy.gmm_learn(v, 3)

(w, mu, sigma) = gmm

print "mu = "
print mu

print "sigma = "
print sigma


muc = numpy.vstack((mu[0, :],
                    mu[0, :])); 
                    
#                    mu[1, :],
#                    mu[1, :],
#                    mu[1, :]))

print "mu=", mu
muc += numpy.random.normal(-0.02, 0.02, size = muc.shape)
print "muc=", muc

fish = ynumpy.fisher(gmm, muc)

print fish
