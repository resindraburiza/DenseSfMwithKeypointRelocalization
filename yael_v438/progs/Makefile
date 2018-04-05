.SUFFIXES: .c .o .swg 

include ../makefile.inc

all: kmeans knn fvecfile ivecfile bvecfile



ifeq "$(USEARPACK)" "yes"
  YAELLDFLAGS+=$(ARPACKLDFLAGS)
  EXTRAMATRIXFLAG=-DHAVE_ARPACK
endif

ifeq "$(USEOPENMP)" "yes"
  EXTRAMATRIXFLAG+=-fopenmp
  YAELLDFLAGS+=-fopenmp
endif


.c.o:
	$(CC) $(CFLAGS) -c $< -o $@ $(FLAGS) $(EXTRACFLAGS) $(YAELCFLAGS) -lm

kmeans: kmeans.o 
	$(CC) -o $@ $^ $(LDFLAGS) $(LAPACKLDFLAGS) $(THREADLDFLAGS) $(YAELLDFLAGS) -lm

knn: knn.o 
	$(CC) -o $@ $^ $(LDFLAGS) $(LAPACKLDFLAGS) $(THREADLDFLAGS) $(YAELLDFLAGS) -lm

fvecfile: fvecfile.o 
	$(CC) -o $@ $^ $(LDFLAGS) $(LAPACKLDFLAGS) $(THREADLDFLAGS)  -lm

ivecfile: ivecfile.o 
	$(CC) -o $@ $^ $(LDFLAGS) $(LAPACKLDFLAGS) $(THREADLDFLAGS)  -lm

bvecfile: bvecfile.o 
	$(CC) -o $@ $^ $(LDFLAGS) $(LAPACKLDFLAGS) $(THREADLDFLAGS)  -lm



#############################
# Dependencies  

# for i in *.c ; do cpp -I.. -MM $i; done

fvecfile.o: fvecfile.c
ivecfile.o: bvecfile.c
bvecfile.o: bvecfile.c
kmeans.o: kmeans.c ../yael/vector.h ../yael/machinedeps.h ../yael/kmeans.h
knn.o: knn.c ../yael/vector.h ../yael/machinedeps.h ../yael/nn.h
clean:
	rm -f  *.o kmeans fvecfile

