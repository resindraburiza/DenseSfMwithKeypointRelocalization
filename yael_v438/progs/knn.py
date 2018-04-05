#!/bin/python

import sys, time
from yael import yael, threads, yutils


# Parameters
d = 128
k = 1
distance_type = 2
slice_size = 16384
matlab = False             # add 1 to the ids

# File format
fmt_b = 'fvecs'
fmt_q = 'fvecs'
fmt_nn = 'ivecs'
fmt_dis = 'fvecs'

fb_name = None         # database filename 
fq_name = None         # query filename 
fnn_name = "nn.out";   # output filename for indexes
fdis_name = "dis.out"; # output filenames for distances


# Main processing - parameters
ma = 1  # multiple assignment
nt = yael.count_cpu()  # automatic detection of number of cores

# Parse argument (and override default)
args = sys.argv[1:]
while args:
     a = args.pop (0)
     if a == '-b':
         fb_name = args.pop(0)
     elif a == '-brawf':
         fb_name = args.pop(0)
         fmt_b = 'rawf'
     elif a == '-q':
         fq_name = args.pop(0)
     elif a == '-qrawf':
         fq_name = args.pop(0)
         fmt_q = 'rawf'
     elif a == '-onn':
         fnn_name = args.pop(0)
     elif a == '-matlab':
         matlab = True
     elif a == '-odis':
         fdis_name = args.pop(0)
     elif a=='-k':
         k = int(args.pop(0))
     elif a=='-d':
         d = int(args.pop(0))
     elif a=='-nt': 
         nt = threads.parse_nt(args.pop(0))
     else: 
         print >> sys.stderr, "unknown arg",a
         sys.exit(1)

(nb, sizeb, szb) = yutils.vecfile_stats (fb_name, d, fmt_b)
(nq, sizeq, szq) = yutils.vecfile_stats (fq_name, d, fmt_q)

(vb, nb) = yutils.load_vectors_fmt (fb_name, fmt_b, d)

print 'nb=%d  db=%d  nq=%d  ' % (nb, sizeb, nq)


nn = yael.ivec (slice_size * k)
nndis = yael.fvec (slice_size * k)

fnn = open (fnn_name, 'w')
fdis = open (fdis_name, 'w')

t0 = time.time()
for istart in xrange (0, nq, slice_size):

    iend = min (istart + slice_size, nq)
    nqslice = iend - istart

    # Read the queries
    (vq, nqslice2) = yutils.load_vectors_fmt (fq_name, fmt_q, d, nqslice, istart, verbose=False)
    assert nqslice == nqslice2

    yael.knn_full_thread(distance_type, nqslice, nb, d, k,
                         vb, vq, None, nn, nndis, nt)

    t1 = time.time()
    print >> sys.stderr, '\r%8.5f%%   -> Elapsed time:%.2fs' % (iend * 100.0 / float(nq), t1-t0)
    
    # Matlab starts indexes from 1
    if matlab: yael.ivec_incr (nn, nqslice * k, 1)

    yael.ivec_fwrite_raw (fnn, nn, nqslice * k)
    yael.fvec_fwrite_raw (fdis, nndis, nqslice * k)

fnn.close()
fdis.close()
