#!/bin/bash
# shellcheck disable=SC2181
#https://www.badunetworks.com/9-sets-of-sample-tc-commands-to-simulate-common-network-scenarios/
tc qdisc show dev eth1 | grep "noqueue 0" >/dev/null
if [ $? -ne 0 ]
then
	echo "deleting old rules on eth1 ..." 
	tc qdisc del dev eth1 root
fi
tc qdisc show dev eth2 | grep "noqueue 0" >/dev/null
if [ $? -ne 0 ]
then
	echo "deleting old rules on eth2 ..." 
	tc qdisc del dev eth2 root
fi
tc qdisc add dev eth1 root netem delay 20ms 8ms rate 1000000kbit
tc qdisc add dev eth2 root netem delay 20ms 8ms rate 1000000kbit
