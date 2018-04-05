.SUFFIXES: .c .o .swg 

include ../../makefile.inc

CC=gcc 

all: test_pca run_pca test_binheap test_eigs test_spectral_clustering test_gmm test_kmeans


ifeq "$(USEARPACK)" "yes"
  EXTRAYAELLDFLAG=$(ARPACKLDFLAGS)
  EXTRAMATRIXFLAG=-DHAVE_ARPACK
endif

ifeq "$(USEOPENMP)" "yes"
  EXTRAMATRIXFLAG+=-fopenmp
  EXTRAYAELLDFLAG+=-fopenmp
endif


#############################
# Various  


.c.o:
	$(CC) $(CFLAGS) -c $< -o $@ $(FLAGS) $(EXTRACFLAGS) $(YAELCFLAGS)

test_pca: test_pca.o 
	$(CC) -o $@ $^ $(LDFLAGS) $(LAPACKLDFLAGS) $(THREADLDFLAGS) $(EXTRAYAELLDFLAG) $(YAELLDFLAGS)

run_pca: run_pca.o 
	$(CC) -o $@ $^ $(LDFLAGS) $(LAPACKLDFLAGS) $(THREADLDFLAGS) $(EXTRAYAELLDFLAG) $(YAELLDFLAGS)

run_eig: run_eig.o 
	$(CC) -o $@ $^ $(LDFLAGS) $(LAPACKLDFLAGS) $(THREADLDFLAGS) $(EXTRAYAELLDFLAG) $(YAELLDFLAGS)

test_binheap: test_binheap.o 
	$(CC) -o $@ $^ $(LDFLAGS) $(LAPACKLDFLAGS) $(THREADLDFLAGS) $(YAELLDFLAGS)

test_gmm: test_gmm.o 
	$(CC) -o $@ $^ $(LDFLAGS) $(LAPACKLDFLAGS) $(THREADLDFLAGS) $(YAELLDFLAGS)

test_eigs: test_eigs.o 
	$(CC) -o $@ $^ $(LDFLAGS) $(LAPACKLDFLAGS) $(THREADLDFLAGS) $(YAELLDFLAGS)

test_spectral_clustering: test_spectral_clustering.o 
	$(CC) -o $@ $^ $(LDFLAGS) $(LAPACKLDFLAGS) $(THREADLDFLAGS) $(EXTRAYAELLDFLAG) $(YAELLDFLAGS)

test_kmeans: test_kmeans.o 
	$(CC) -o $@ $^ $(LDFLAGS) $(LAPACKLDFLAGS) $(THREADLDFLAGS) $(YAELLDFLAGS)


#############################
# Dependencies  

# for i in *.c ; do cpp -I../.. -MM $i; done
test_binheap.o: test_binheap.c ../../yael/binheap.h
test_eigs.o: test_eigs.c ../../yael/eigs.h ../../yael/vector.h \
  ../../yael/matrix.h
test_gmm.o: test_gmm.c ../../yael/vector.h ../../yael/machinedeps.h \
  ../../yael/gmm.h
test_kmeans.o: test_kmeans.c ../../yael/vector.h ../../yael/kmeans.h \
  ../../yael/machinedeps.h
test_pca.o: test_pca.c ../../yael/vector.h ../../yael/matrix.h
run_pca.o: run_pca.c ../../yael/vector.h ../../yael/matrix.h
run_eig.o: run_eig.c ../../yael/vector.h ../../yael/matrix.h
test_spectral_clustering.o: test_spectral_clustering.c \
  ../../yael/spectral_clustering.h ../../yael/vector.h



clean:
	rm -f *.o test_pca run_pca test_binheap test_gmm test_eigs test_spectral_clustering test_kmeans

