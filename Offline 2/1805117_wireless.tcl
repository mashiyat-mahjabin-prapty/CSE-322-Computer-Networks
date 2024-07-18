# simulator
set ns [new Simulator]


# ======================================================================
# Define options

set val(chan)         Channel/WirelessChannel           ;# channel type
set val(prop)         Propagation/TwoRayGround          ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna               ;# Antenna type
set val(ll)           LL                                ;# Link layer type
set val(ifq)          Queue/DropTail/PriQueue           ;# Interface queue type
set val(ifqlen)       50                                ;# max packet in ifq
set val(netif)        Phy/WirelessPhy         ;# network interface type
set val(mac)          Mac/802_11                     ;# MAC type
set val(rp)           DSDV                              ;# ad-hoc routing protocol 
# set val(nn)           40                               ;# number of mobilenodes
# =======================================================================

set val(side) [lindex $argv 0]  ;# area side
set val(nn) [lindex $argv 1]  ;# number of mobilenodes
set val(nf) [lindex $argv 2]  ;# number of flows

# trace file
set trace_file [open 1805117_trace.tr w]
$ns trace-all $trace_file

# set length 500
# set width 500
# nam file
set nam_file [open 1805117_animation.nam w]
$ns namtrace-all-wireless $nam_file $val(side) $val(side)

# topology: to keep track of node movements
set topo [new Topography]
$topo load_flatgrid $val(side) $val(side) ;# sidem x sidem area


# general operation director for mobilenodes
create-god $val(nn)


# node configs
# ======================================================================

$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -topoInstance $topo \
                -channelType $val(chan) \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace OFF \
                -movementTrace OFF

# create nodes
set row 0
set col 0

for {set i 0} {$i < $val(nn) } {incr i} {
    set node($i) [$ns node]
    $node($i) random-motion 0       ;# disable random motion

    $node($i) set X_ [expr (5000 * $col) / $val(nn)]
    $node($i) set Y_ [expr ($row) / $val(nn)]
    $node($i) set Z_ 0

    $ns initial_node_pos $node($i) 20
    
    set col [expr $col + 1]
    if {$i % 10 == 9} {
        set row [expr $row + 5000]
        set col 0
    }
} 

# producing node movements with uniform random speed
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at [expr int(20 * rand()) + 5] "$node($i) setdest [expr int(10000 * rand()) % $val(side) + 0.5] [expr int(10000 * rand()) % $val(side) + 0.5] [expr int(100 * rand()) % 5 + 1]"
}

# Traffic
# set val(nf)         20                ;# number of flows

# generating traffic/flow
# picking random sink node
set dest [expr int(1000 * rand()) % $val(nn)]

for {set i 0} {$i < $val(nf)} {incr i} {
    # picking random source node
    while {$dest == $dest} {
        set src [expr int(1000 * rand()) % $val(nn)]
        if {$src != $dest} {
            break
        }
    }

    # configuring traffic/flow
    # creating transport-layer agents
    set tcp [new Agent/TCP]
    set tcp_sink [new Agent/TCPSink]

    # attaching agents to nodes
    $ns attach-agent $node($src) $tcp
    $ns attach-agent $node($dest) $tcp_sink

    # connecting agents
    $ns connect $tcp $tcp_sink

    # marking flow
    $tcp set fid_ $i

    # creating application-layer traffic/flow generator
    set telnet [new Application/Telnet]
    
    # attach to agent
    $telnet attach-agent $tcp

    # starting traffic/flow generation
    $ns at 1.0 "$telnet start"
}



# End Simulation

# Stop nodes
for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at 50.0 "$node($i) reset"
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

$ns at 50.0001 "finish"
$ns at 50.0002 "halt_simulation"




# Run simulation
puts "Simulation starting"
$ns run
