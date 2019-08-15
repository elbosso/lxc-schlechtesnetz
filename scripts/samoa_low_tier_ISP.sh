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
tc qdisc add dev eth2 root netem delay 200ms 40ms 25% loss 15.3% 25% duplicate 1% corrupt 0.1% reorder 5% 50%
tc qdisc add dev eth1 root netem delay 200ms 40ms 25% loss 15.3% 25% duplicate 1% corrupt 0.1% reorder 5% 50%
