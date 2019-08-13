#!/bin/bash
#https://opensourceforu.com/2012/06/bandwidth-throttling-netem-network-emulation/
bruttobw=${1}	#1GBit
portbw=${2}	#512kbit
port=${3}	#7001

tc qdisc show dev eth1 | grep "noqueue 0" >/dev/null
if [ $? -ne 0 ]
then
	echo "deleting old rules..." 
	tc qdisc del dev eth1 root
fi
tc qdisc add dev eth1 root handle 1: cbq avpkt 1000 bandwidth ${bruttobw} 
tc class add dev eth1 parent 1: classid 1:1 cbq rate ${portbw} allot 1500 prio 3 bounded isolated
tc filter add dev eth1 parent 1: protocol ip u32 match ip protocol 6 0xff match ip dport ${port} 0xffff flowid 1:1
