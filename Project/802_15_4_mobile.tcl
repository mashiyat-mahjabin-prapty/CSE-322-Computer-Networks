# simulator
set ns [new Simulator]

set opt(speed) [lindex $argv 0]  ;# speed of nodes
set opt(nn) [lindex $argv 1]  ;# number of mobilenodes
set opt(nf) [lindex $argv 2]  ;# number of flows
set opt(np) [lindex $argv 3]  ;# number of packets per second
set opt(g) [lindex $argv 4] ; # value of gamma
set opt(ifqlen) [expr 2*$opt(nf)] ;# max packet in ifq

Queue/RED set thresh_ [expr $opt(ifqlen) * 0.2]
Queue/RED set maxthresh_ [expr $opt(ifqlen) * 0.7]
Queue/RED set q_weight_ 0.002
Queue/RED set maxp_ 0.02
Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
Queue/RED set gentle_ false
Queue/RED set mean_pktsize_ 50
Queue/RED set gamma_ $opt(g)

# ======================================================================
# Define options

set opt(chan)         Channel/WirelessChannel           ;# channel type
set opt(prop)         Propagation/TwoRayGround          ;# radio-propagation model
set opt(ant)          Antenna/OmniAntenna               ;# Antenna type
set opt(ll)           LL                                ;# Link layer type
set opt(ifq)          Queue/RED           				;# Interface queue type
set opt(netif)        Phy/WirelessPhy/802_15_4          ;# network interface type
set opt(mac)          Mac/802_15_4                      ;# MAC type
set opt(rp)           DSDV                              ;# ad-hoc routing protocol
set opt(energymodel)  EnergyModel                       ;# energy model type
set opt(initialenergy)  15                            	;# initial energy in Joules
# set val(nn)           40                              ;# number of mobilenodes
# =======================================================================




# trace file
set trace_file [open trace_802_15_4.tr w]
$ns trace-all $trace_file

set opt(side) 500
# set width 500
# nam file
set nam_file [open animation_802_15_4.nam w]
$ns namtrace-all-wireless $nam_file $opt(side) $opt(side)

# topology: to keep track of node movements
set topo [new Topography]
$topo load_flatgrid $opt(side) $opt(side) ;# sidem x sidem area


# general operation director for mobilenodes
create-god $opt(nn)


# node configs
# ======================================================================

$ns node-config -adhocRouting $opt(rp) \
                -llType $opt(ll) \
                -macType $opt(mac) \
                -ifqType $opt(ifq) \
                -ifqLen $opt(ifqlen) \
                -antType $opt(ant) \
                -propType $opt(prop) \
                -phyType $opt(netif) \
                -topoInstance $topo \
                -channelType $opt(chan) \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace ON \
                -movementTrace OFF \
                -energyModel $opt(energymodel) \
			    -idlePower 0.45 \
			    -rxPower 0.9 \
			    -txPower 0.4 \
          		-sleepPower 0.05 \
          		-transitionPower 0.2 \
          		-transitionTime 0.005 \
			    -initialEnergy $opt(initialenergy)

# create nodes
set row 0
set col 0

for {set i 0} {$i < $opt(nn) } {incr i} {
    set node($i) [$ns node]
    $node($i) random-motion 0       ;# disable random motion

    $node($i) set X_ [expr (5000 * $col) / $opt(nn)]
    $node($i) set Y_ [expr ($row) / $opt(nn)]
    $node($i) set Z_ 0

    $ns initial_node_pos $node($i) 20
    
    set col [expr $col + 1]
    if {$i % 10 == 9} {
        set row [expr $row + 5000]
        set col 0
    }
} 

# producing node movements with uniform random speed
for {set i 0} {$i < $opt(nn)} {incr i} {
    $ns at [expr int(20 * rand()) + 5] "$node($i) setdest [expr int(10000 * rand()) % $opt(side) + 0.5] [expr int(10000 * rand()) % $opt(side) + 0.5] $opt(speed)"
}

# Traffic
# set val(nf)         20                ;# number of flows

# generating traffic/flow
# picking random sink node


for {set i 0} {$i < $opt(nf)} {incr i} {
    # picking random source node
    set dest [expr int(1000 * rand()) % $opt(nn)]

	#set src [expr ($dest * 3) % $opt(nn)]
 	set src [expr ($dest + 2) % $opt(nn)]
		
    # configuring traffic/flow
    # creating transport-layer agents
    set tcp [new Agent/TCP]
	# Set the number of packets to send
	set num_packets $opt(np)

	# Set the window size of the TCP agent
	$tcp set window_ $num_packets

    set tcp_sink [new Agent/TCPSink]

    # attaching agents to nodes
    $ns attach-agent $node($src) $tcp
    $ns attach-agent $node($dest) $tcp_sink
	
    # connecting agents
    $ns connect $tcp $tcp_sink

    # marking flow
    $tcp set fid_ $i

    # creating application-layer traffic/flow generator
    set ftp [new Application/FTP]
    
    # attach to agent
    $ftp attach-agent $tcp
	
    # starting traffic/flow generation
    $ns at 1.0 "$ftp start"
}

# End Simulation

# Stop nodes
for {set i 0} {$i < $opt(nn)} {incr i} {
    $ns at 20.0 "$node($i) reset"
}

# call final function
proc finish {} {
    global ns trace_file nam_file
    $ns flush-trace
    close $trace_file
    close $nam_file
}

proc halt_simulation {} {
    global ns
    puts "Simulation ending"
    $ns halt
}

$ns at 20.0001 "finish"
$ns at 20.0002 "halt_simulation"




# Run simulation
puts "Simulation starting"
$ns run
