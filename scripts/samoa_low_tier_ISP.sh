#!/bin/bash
# shellcheck disable=SC2181
#https://calomel.org/network_loss_emulation.html
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
delay1=200ms
delay2=40ms
rate=600000kbit
tc qdisc add dev eth1 root handle 1: tbf rate "$rate" burst 32kbit latency 400ms
tc qdisc add dev eth1 parent 1:1 handle 10: netem delay "$delay1" "$delay2" distribution normal 25% loss 15.3% 25% duplicate 1% corrupt 0.1% reorder 5% 50%
tc qdisc add dev eth2 root handle 1: tbf rate "$rate" burst 32kbit latency 400ms
tc qdisc add dev eth2 parent 1:1 handle 10: netem delay "$delay1" "$delay2" distribution normal 25% loss 15.3% 25% duplicate 1% corrupt 0.1% reorder 5% 50%

