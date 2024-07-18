# simulator
set ns [new Simulator]

set opt(nn) [lindex $argv 0]  ;# number of nodes
set opt(g) [lindex $argv 1]  ;# number of nodes
#set opt(nf) [lindex $argv 1]  ;# number of flows
#set opt(np) [lindex $argv 2] ;# number of packets

Queue/RED set thresh_ [expr $opt(nn)*2*0.2]
Queue/RED set maxthresh_ [expr $opt(nn)*2*0.7]
Queue/RED set q_weight_ 1
Queue/RED set linterm_ 20
Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
Queue/RED set gentle_ false
Queue/RED set mean_pktsize_ 1000
Queue/RED set gamma_ $opt(g)

#Define different colors for data flows (for NAM)
$ns color 1 Blue
$ns color 2 Red

#Open the NAM file and trace file
set nam_file [open animation_wired.nam w]
set trace_file [open trace_wired.tr w]
$ns namtrace-all $nam_file
$ns trace-all $trace_file

#Define a 'finish' procedure
proc finish {} {
    global ns nam_file trace_file
    $ns flush-trace 
    #Close the NAM trace file
    close $nam_file
    close $trace_file
    #Execute NAM on the trace file
    # exec nam out.nam &
    exit 0
}

for {set i 0} {$i < $opt(nn) } {incr i} {
    set node($i) [$ns node]
} 
set node($opt(nn)) [$ns node]
#Create links between the nodes
# ns <link-type> <node1> <node2> <bandwidht> <delay> <queue-type-of-node2>
for {set i 2} {$i < $opt(nn) } {incr i} {
    $ns duplex-link $node($i) $node(1) 100Mbps 5ms RED
} 

$ns duplex-link $node(0) $node($opt(nn)) 100Mbps 5ms DropTail
$ns duplex-link $node(0) $node(1) 10Mbps 100ms RED

#Set Queue Size of link (n2-n3) to 10
$ns queue-limit $node(0) $node(1) [expr $opt(nn)*2]
# $ns duplex-link-op $n2 $n3 queuePos 0.5

#Monitor the queue for link (n2-n3). (for NAM)
$ns duplex-link-op $node(0) $node(1) queuePos 0.5


#Setup a TCP connection
#Setup a flow
for {set i 2} {$i < $opt(nn)} {incr i} {
    set tcp [new Agent/TCP]

	# set the buffer size to 500 packets
    set packetSize 8032
    set bufferSize [expr {500 * $packetSize}]
    $tcp set sndbuf_ $bufferSize
    $tcp set rcvbuf_ $bufferSize

    # Set the number of packets to send
	set num_packets 500

	# Set the window size of the TCP agent
	$tcp set window_ $num_packets

    set tt [expr $i % $opt(nn)]
    if {$tt == 0 || $tt == 1} {
        set tt [expr $tt + 2]
    }
	$ns attach-agent $node($tt) $tcp
	set sink [new Agent/TCPSink]
	$ns attach-agent $node($opt(nn)) $sink
	$ns connect $tcp $sink
	$tcp set fid_ $i

	#Setup a FTP Application over TCP connection
	set ftp [new Application/FTP]
	$ftp attach-agent $tcp
	$ftp set type_ FTP

	$ns at 1.0 "$ftp start"
} 

#Call the finish procedure after 40 seconds of simulation time
$ns at 40.0 "finish"


#Run the simulation
$ns run
