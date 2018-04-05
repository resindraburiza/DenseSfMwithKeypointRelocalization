% Test program for function test_yael_kmin, and timings comparison
d = 100000;
n = 100; 
k = 100;

a = single (rand (d, n)); 

% Just the minimal value
tic ; [v, i] = min(a) ; tmin = toc ;

% use the yael function to find the minimum only
tic; [val,idx] = yael_kmin (a, 1) ; tymin = toc;

% A standard matlab full sort (not good to find knn)
tic ; [val,idx_matlab] = sort(a); tsort = toc ;

% use to find the k smallest values
tic; [val,idx_yael] = yael_kmin (a, k) ; tykmin = toc; 

verify_result = all( idx_matlab(1:k,:) == idx_yael(1:k,:))


fprintf (['Timings:\n  Matlab min search: %.3f\n  Yael min search:   %.3f\n' ...
	  '  Yael k-min search: %.3f\n  Matlab sort:       %.3f\n'], ... 
	 tmin, tymin, tykmin, tsort);
