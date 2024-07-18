#!/bin/bash

echo -e "\nscript.sh running\n"

gamma=(0 3 6 9 12 15)

baseline_area_size=500
baseline_num_nodes=40
baseline_num_flows=20
baseline_num_packets=100

for g in "${gamma[@]}"; do 
    echo -e "\nRunning for gamma: $g\n"
    touch result_11_area_$g.txt
    touch result_11_nn_$g.txt
    touch result_11_nf_$g.txt
    touch result_11_np_$g.txt

    #varying area size
    echo -e "Area-Size-(m)\nNetwork-Throughput-(kilobits/sec) End-to-End-Delay-(sec) Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%) Energy-Consumed-(J)" > result_11_area_$g.txt
    echo -e "Changing area size\n"

    for((i=0; i<5; i++)); do
        area_size=`expr 250 + $i \* 250`
        echo -e $area_size >> result_11_area_$g.txt

        echo -e "802_11_static.tcl: running with $area_size $baseline_num_nodes $baseline_num_flows $baseline_num_packets $g\n"
        ns 802_11_static.tcl $area_size $baseline_num_nodes $baseline_num_flows $baseline_num_packets $g
        awk -f 1805117_parse_802_11.awk trace_802_11.tr >> result_11_area_$g.txt 
    done

    #varying number of nodes
    echo -e "Number-of-Nodes\nNetwork-Throughput-(kilobits/sec) End-to-End-Delay-(sec) Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%) Energy-Consumed-(J)" > result_11_nn_$g.txt
    echo -e "Changing number of nodes\n"

    for((i=0; i<5; i++)); do
        num_nodes=`expr 20 + $i \* 20`
        echo -e $num_nodes >> result_11_nn_$g.txt

        echo -e "802_11_static.tcl: running with $baseline_area_size $num_nodes $baseline_num_flows $baseline_num_packets $g\n"
        ns 802_11_static.tcl $baseline_area_size $num_nodes $baseline_num_flows $baseline_num_packets $g
        awk -f 1805117_parse_802_11.awk trace_802_11.tr >> result_11_nn_$g.txt 
    done

    #varying number of flows
    echo -e "Number-of-Flows\nNetwork-Throughput-(kilobits/sec) End-to-End-Delay-(sec) Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%) Energy-Consumed-(J)" > result_11_nf_$g.txt
    echo -e "Changing number of flows\n"

    for((i=0; i<5; i++)); do
        num_flows=`expr 10 + $i \* 10`
        echo -e $num_flows >> result_11_nf_$g.txt

        echo -e "802_11_static.tcl: running with $baseline_area_size $baseline_num_nodes $num_flows $baseline_num_packets $g\n"
        ns 802_11_static.tcl $baseline_area_size $baseline_num_nodes $num_flows $baseline_num_packets $g
        awk -f 1805117_parse_802_11.awk trace_802_11.tr >> result_11_nf_$g.txt 
    done

    #varying number of packets
    echo -e "Number-Of-Packets\nNetwork-Throughput-(kilobits/sec) End-to-End-Delay-(sec) Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%) Energy-Consumed-(J)" > result_11_np_$g.txt
    echo "Changing area size\n"

    for((i=0; i<5; i++)); do
        num_packets=`expr 100 + $i \* 100`
        echo -e $num_packets >> result_11_np_$g.txt

        echo -e "802_11_static.tcl: running with $baseline_area_size $baseline_num_nodes $baseline_num_flows $num_packets $g\n"
        ns 802_11_static.tcl $baseline_area_size $baseline_num_nodes $baseline_num_flows $num_packets $g
        awk -f 1805117_parse_802_11.awk trace_802_11.tr >> result_11_np_$g.txt 
    done
done

echo -e "script.sh:over"
