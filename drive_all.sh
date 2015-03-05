#! /bin/bash 

#set -x
CDF="learning"
CDF="search" 


#for CDF in "learning"; do
for CDF in "search" "learning"; do
    if [ "$CDF" == "search" ]; then MEAN_FLOW_SIZE=1661480; fi #1138 packets * 1460B
    if [ "$CDF" == "learning" ]; then MEAN_FLOW_SIZE=7470820; fi #5117 packets * 1460B

    #for type in "qjump" ; do
    for type in "baseline" "pfabric" "dctcp"; do
        if [ "$type" == "baseline" ]; then con_per_pair=8; fi
        if [ "$type" == "dctcp" ]; then con_per_pair=8; fi
        if [ "$type" == "pfabric" ]; then con_per_pair=1; fi
        if [ "$type" == "qjump" ]; then con_per_pair=10; fi
 
        pids=""
        #for i in "0.95" "0.99" "0.999"; do 
        #for i in "0.8" ; do
        for i in "0.8" "0.7" "0.6" "0.5" "0.4" "0.3" "0.2" "0.1"; do 
            name=${type}_${CDF}_$i
            mkdir -p $name
            cp *.tcl *.sh $name
            cd $name 
            cmd="time ./run_${type}.sh 100000 $i $con_per_pair ${CDF}_CDF.tcl $MEAN_FLOW_SIZE &> $name.log &"
            echo $cmd
            eval $cmd 
            pids="$pids $!"
            cd -
        done 
    
        for pid in $pids; do
            echo "Waiting for $pid"
            wait $pid
        done

    done
done
