#!/bin/bash

echo -e "\nscript.sh running\n"

gamma=(0 3 6 9 12 15)

baseline_speed=10
baseline_num_nodes=40
baseline_num_flows=20
baseline_num_packets=100

for g in "${gamma[@]}"; do 
    echo -e "\nRunning for gamma: $g\n"

    touch result_15_speed_$g.txt
    touch result_15_nn_$g.txt
    touch result_15_nf_$g.txt
    touch result_15_np_$g.txt

    #varying speed
    echo -e "Speed-(m/s)\nNetwork-Throughput-(kilobits/sec) End-to-End-Delay-(sec) Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%) Energy-Consumed-(J)" > result_15_speed_$g.txt
    echo -e "Changing speed\n"

    for((i=0; i<5; i++)); do
        speed=`expr 5 + $i \* 5`
        echo -e $speed >> result_15_speed_$g.txt

        echo -e "802_15_4_mobile.tcl: running with $speed $baseline_num_nodes $baseline_num_flows $baseline_num_packets $g\n"
        ns 802_15_4_mobile.tcl $speed $baseline_num_nodes $baseline_num_flows $baseline_num_packets $g
        awk -f 1805117_parse_802_15.awk trace_802_15_4.tr >> result_15_speed_$g.txt 
    done

    #varying number of nodes
    echo -e "Number-of-Nodes\nNetwork-Throughput-(kilobits/sec) End-to-End-Delay-(sec) Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%) Energy-Consumed-(J)" > result_15_nn_$g.txt
    echo -e "Changing number of nodes\n"

    for((i=0; i<5; i++)); do
        num_nodes=`expr 20 + $i \* 20`
        echo -e $num_nodes >> result_15_nn_$g.txt

        echo -e "802_15_4_mobile.tcl: running with $baseline_speed $num_nodes $baseline_num_flows $baseline_num_packets $g\n"
        ns 802_15_4_mobile.tcl $baseline_speed $num_nodes $baseline_num_flows $baseline_num_packets $g
        awk -f 1805117_parse_802_15.awk trace_802_15_4.tr >> result_15_nn_$g.txt 
    done

    #varying number of flows
    echo -e "Number-of-Flows\nNetwork-Throughput-(kilobits/sec) End-to-End-Delay-(sec) Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%) Energy-Consumed-(J)" > result_15_nf_$g.txt
    echo -e "Changing number of flows\n"

    for((i=0; i<5; i++)); do
        num_flows=`expr 10 + $i \* 10`
        echo -e $num_flows >> result_15_nf_$g.txt

        echo -e "802_15_4_mobile.tcl: running with $baseline_speed $baseline_num_nodes $num_flows $baseline_num_packets $g\n"
        ns 802_15_4_mobile.tcl $baseline_speed $baseline_num_nodes $num_flows $baseline_num_packets $g
        awk -f 1805117_parse_802_15.awk trace_802_15_4.tr >> result_15_nf_$g.txt 
    done

    #varying number of packets
    echo -e "Number-Of-Packets\nNetwork-Throughput-(kilobits/sec) End-to-End-Delay-(sec) Packet-Delivery-Ratio-(%) Packet-Drop-Ratio-(%) Energy-Consumed-(J)" > result_15_np_$g.txt
    echo "Changing number of packets\n"

    for((i=0; i<5; i++)); do
        num_packets=`expr 100 + $i \* 100`
        echo -e $num_packets >> result_15_np_$g.txt

        echo -e "802_15_4_static.tcl: running with $baseline_speed $baseline_num_nodes $baseline_num_flows $num_packets $g\n"
        ns 802_15_4_mobile.tcl $baseline_speed $baseline_num_nodes $baseline_num_flows $num_packets $g
        awk -f 1805117_parse_802_15.awk trace_802_15_4.tr >> result_15_np_$g.txt 
    done

done

echo -e "script.sh:over"
