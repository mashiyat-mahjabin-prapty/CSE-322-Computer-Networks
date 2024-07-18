#!/bin/bash

echo "\nscript.sh running\n"
touch result.txt

baseline_area_size=500
baseline_num_nodes=40
baseline_num_flows=20

#varying area size
echo -e "Area-Size-(m)\nNetwork-Throughput-(kilobits/sec) End-to-End-Delay-(sec) Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%)" > result.txt
echo "Changing area size\n"

for((i=0; i<5; i++)); do
    area_size=`expr 250 + $i \* 250`
    echo -e $area_size >> result.txt

    echo -e "1805117_wireless.tcl: running with $area_size $baseline_num_nodes $baseline_num_flows\n"
    ns 1805117_wireless.tcl $area_size $baseline_num_nodes $baseline_num_flows
    awk -f 1805117_parse.awk 1805117_trace.tr >> result.txt 
done

echo -e "plotter.py:running\n"
python plotter.py 

#varying number of nodes
echo -e "Number-of-Nodes\nNetwork-Throughput-(kilobits/sec) End-to-End-Delay-(sec) Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%)" > result.txt
echo -e "Changing number of nodes\n"

for((i=0; i<5; i++)); do
    num_nodes=`expr 20 + $i \* 20`
    echo -e $num_nodes >> result.txt

    echo -e "1805117_wireless.tcl.tcl: running with $baseline_area_size $num_nodes $baseline_num_flows\n"
    ns 1805117_wireless.tcl $baseline_area_size $num_nodes $baseline_num_flows
    awk -f 1805117_parse.awk 1805117_trace.tr >> result.txt 
done

echo -e "plotter.py:running\n"
python plotter.py

#varying number of flows
echo -e "Number-of-Flows\nNetwork-Throughput-(kilobits/sec) End-to-End-Delay-(sec) Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%)" > result.txt
echo -e "Changing number of flows\n"

for((i=0; i<5; i++)); do
    num_flows=`expr 10 + $i \* 10`
    echo -e $num_flows >> result.txt

    echo -e "1805117_wireless.tcl.tcl: running with $baseline_area_size $baseline_num_nodes $num_flows\n"
    ns 1805117_wireless.tcl $baseline_area_size $baseline_num_nodes $num_flows
    awk -f 1805117_parse.awk 1805117_trace.tr >> result.txt 
done

echo -e "plotter.py:running\n"
python plotter.py

echo -e "script.sh:over"