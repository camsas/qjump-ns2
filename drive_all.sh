#! /bin/bash 

# Copyright (c) 2015, Matthew P. Grosvenor
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# * Neither the name of the project, the name of copyright holder nor the names 
#   of its contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
