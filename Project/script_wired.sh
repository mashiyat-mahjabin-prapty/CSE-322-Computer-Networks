#!/bin/bash

echo -e "\nscript.sh running\n"

gamma=(0 3 6 9 12 15)

for g in "${gamma[@]}"; do 
    echo -e "\nRunning for gamma: $g\n"
    touch result_wired_$g.txt

    #varying number of nodes
    echo -e "Number-of-Nodes\nNetwork-Throughput-(kilobits/sec) End-to-End-Delay-(sec) Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%)" > result_wired_$g.txt
    echo -e "Changing number of nodes\n"

    for((i=0; i<5; i++)); do
        num_nodes=`expr 20 + $i \* 20`
        echo -e $num_nodes >> result_wired_$g.txt

        echo -e "wired.tcl: running with $num_nodes $g\n"
        ns wired.tcl $num_nodes $g
        awk -f 1805117_parse_wired.awk trace_wired.tr >> result_wired_$g.txt 
    done
done 

echo -e "script.sh:over"
