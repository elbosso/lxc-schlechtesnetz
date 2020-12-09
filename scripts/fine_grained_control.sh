#!/bin/bash
# shellcheck disable=SC2181
#https://opensourceforu.com/2012/06/bandwidth-throttling-netem-network-emulation/

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

#bands 3: bedeutet wir können bei parent 1:x für x bis 3 gehen,
#was hinter parent steht (y:x) ist die flowid für die Filter unten
#die xx: fassen die anzuwendenden Regeln zusammen 
#mit den Regeln hier und den Filtern unten wird
# netzwerk management (arp, dhcp,... ) nicht beeinflusst
# ipv4 ssh nicht beeinflusst
# ipv6 https wird auf ein mbit begrenzt
# alles andere wird auf 356 kbit begrenzt
tc qdisc add dev eth1 root handle 1: prio bands 3 priomap 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
tc qdisc add dev eth2 root handle 1: prio bands 3 priomap 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1

tc qdisc add dev eth1 parent 1:1 handle 10: pfifo limit 1000
tc qdisc add dev eth2 parent 1:1 handle 10: pfifo limit 1000

tc qdisc add dev eth1 parent 1:2 handle 20: netem delay 17.5ms 4.5ms distribution normal
tc qdisc add dev eth2 parent 1:2 handle 20: netem delay 17.5ms 4.5ms distribution normal

tc qdisc add dev eth1 parent 20: handle 21: tbf rate 256kbit burst 32kbit latency 400ms
tc qdisc add dev eth2 parent 20: handle 21: tbf rate 256kbit burst 32kbit latency 400ms

tc qdisc add dev eth1 parent 1:3 handle 30: netem delay 17.5ms 4.5ms distribution normal
tc qdisc add dev eth2 parent 1:3 handle 30: netem delay 17.5ms 4.5ms distribution normal

tc qdisc add dev eth1 parent 30: handle 31: tbf rate 1mbit burst 32kbit latency 400ms
tc qdisc add dev eth2 parent 30: handle 31: tbf rate 1mbit burst 32kbit latency 400ms

for vlanif in eth1 eth2
do
        # ARP
        tc filter add dev $vlanif parent 1: prio 1 protocol arp u32 \
            match u32 0 0 \
            flowid 1:1

        # ICMP
        tc filter add dev $vlanif parent 1: prio 2 protocol ip u32 \
            match ip protocol 1 0xff \
            flowid 1:1

        # IGMP
        tc filter add dev $vlanif parent 1: prio 3 protocol ip u32 \
            match ip protocol 2 0xff \
            flowid 1:1

        # DHCP
        tc filter add dev $vlanif parent 1: prio 4 protocol ip u32 \
            match ip protocol 17 0xff  \
            match ip dport 67 0xffff \
            flowid 1:1
        tc filter add dev $vlanif parent 1: prio 4 protocol ip u32 \
            match ip protocol 17 0xff  \
            match ip dport 68 0xffff \
            flowid 1:1

        # ICMPv6
        tc filter add dev $vlanif parent 1: prio 5 protocol ipv6 u32 \
            match ip6 protocol 58 0xff \
            flowid 1:1

        # ICMPv6 (after a 8-byte IPv6 header extension, which itself has next header field at byte 0)
        tc filter add dev $vlanif parent 1: prio 6 protocol ipv6 u32 \
            match u8 58 0xff at nexthdr+0 \
            flowid 1:1

        # DHCPv6
        tc filter add dev $vlanif parent 1: prio 7 protocol ipv6 u32 \
            match ip6 protocol 17 0xff  \
            match ip6 dport 546 0xffff \
            flowid 1:1
        tc filter add dev $vlanif parent 1: prio 7 protocol ipv6 u32 \
            match ip6 protocol 17 0xff  \
            match ip6 dport 547 0xffff \
            flowid 1:1

        # ssh
        tc filter add dev $vlanif parent 1: prio 8 protocol ip u32 \
            match ip sport 22 0xffff \
            flowid 1:1
        tc filter add dev $vlanif parent 1: prio 8 protocol ip u32 \
            match ip sport 22 0xffff \
            flowid 1:1
        # ssh
        tc filter add dev $vlanif parent 1: prio 8 protocol ip u32 \
            match ip dport 22 0xffff \
            flowid 1:1
        tc filter add dev $vlanif parent 1: prio 8 protocol ip u32 \
            match ip dport 22 0xffff \
            flowid 1:1

        # https
        tc filter add dev $vlanif parent 1: prio 9 protocol ipv6 u32 \
            match ip6 sport 443 0xffff \
            flowid 1:3
        tc filter add dev $vlanif parent 1: prio 9 protocol ipv6 u32 \
            match ip6 sport 443 0xffff \
            flowid 1:3
        # https
        tc filter add dev $vlanif parent 1: prio 9 protocol ipv6 u32 \
            match ip6 dport 443 0xffff \
            flowid 1:3
        tc filter add dev $vlanif parent 1: prio 9 protocol ipv6 u32 \
            match ip6 dport 443 0xffff \
            flowid 1:3

done

