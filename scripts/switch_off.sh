#!/bin/bash
tc qdisc show dev eth1 | grep "noqueue 0" >/dev/null
if [ $? -ne 0 ]
then
	echo "deleting old rules for eth1 ..." 
	tc qdisc del dev eth1 root
else
	echo "no rule active on eth1 - nothing to do!"
fi
tc qdisc show dev eth2 | grep "noqueue 0" >/dev/null
if [ $? -ne 0 ]
then
	echo "deleting old rules for eth2 ..." 
	tc qdisc del dev eth2 root
else
	echo "no rule active on eth2 - nothing to do!"
fi
