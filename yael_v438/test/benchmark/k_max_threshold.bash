
export LD_LIBRARY_PATH=../../yael/



for((n=100; n<=1000*10000; n *= 10))
do 
    nrepeat=$[100000 / n]; 
    if [ $nrepeat == 0 ]; then
	nrepeat=1
    fi
    echo =================== n = $n
    ./loop_k_max $n $nrepeat | tee data/quantiles_n$n.dat
done
