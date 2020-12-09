#!/bin/bash
# shellcheck disable=SC2181
script="$0"
script_dir=$(dirname "$script")

if [ "$#" -ne 4 ]; then
    echo "Illegal number of parameters"
	echo "$script containername control_dev consumer_dev server_dev"
	echo -e "\tcontainername\tname of the container to be created"
	echo -e "\tcontrol_dev\tdevice for controlling the container via ssh"
	echo -e "\tconsumer_dev\tupstream device coupled by bridge"
	echo -e "\tserver_dev\tdownstream device coupled by bridge"
fi

#config variables from command line arguments
container="$1"
controldev="$2"
consumerdev="$3"
serverdev="$4"

echo "operating from within $script_dir"

ip link show "$controldev" > /dev/null 2>&1 
if [ $? -ne 0 ]
then
        echo "$controldev does not exist - exiting..."
        exit 1
fi
ip link show "$serverdev" > /dev/null 2>&1 
if [ $? -ne 0 ]
then
        echo "$serverdev does not exist - exiting..."
        exit 2
fi
ip link show "$consumerdev" > /dev/null 2>&1 
if [ $? -ne 0 ]
then
        echo "$consumerdev does not exist - exiting..."
        exit 3
fi

echo "building container $container..."

lxc-info -n "$container"
if [ $? -eq 0 ]
then
        echo "container already there - aborting!"
        exit 1
fi

#lxc-create for the container - at this moment, we always build a focal beaver ubuntu container
lxc-create -t download -n "$container" -- -d ubuntu -r focal  -a amd64

lxc-info -n "$container"
if [ $? -ne 0 ]
then
        echo "container creation failed - aborting!"
        exit 2
fi

rootfs=$(lxc-info -n "$container" -c lxc.rootfs.path|rev|cut -d " " -f 1|cut -d ":" -f 1|rev)

#changing the config of the container so it has the interfaces named
#at startup properly assigned
sed -i "s/lxc.net.0.link =.*/lxc.net.0.link = $controldev/g" "$rootfs/.."/config
{ echo "lxc.net.1.type = veth" ;\
echo "lxc.net.1.link = $consumerdev" ;\
echo "lxc.net.1.flags = up" ;\
echo "lxc.net.2.type = veth" ;\
echo "lxc.net.2.link = $serverdev" ;\
echo "lxc.net.2.flags = up" ; } >> "/$rootfs/.."/config

#starting the container
lxc-start -n "$container"
lxc-wait -n "$container" -s RUNNING

#netplan: arghhh! We want ifupdown and so we need to get rid of 
#this junk!
lxc-attach -n "$container" -- apt-get -y remove netplan

#Now we install all needed packages
#(or some the author deems necessary...)
sleep 5
lxc-attach -n "$container" -- apt-get update
lxc-attach -n "$container" -- apt-get -y upgrade
lxc-attach -n "$container" -- bash -c "echo 'wireshark-common wireshark-common/install-setuid boolean true' | debconf-set-selections"
lxc-attach -n "$container" -- bash -c "DEBIAN_FRONTEND=noninteractive apt-get -y install joe screen conky ifupdown openssh-server bridge-utils iproute2 iptables git wireshark jq curl python3-pip"

lxc-attach -n "$container" -- pip3 install tcconfig

#Because we do not use or require LXD at this point,
#we can not use lxc push file
#so we have to cp files and to be able to do so - we
#need to know where the root file system of the container is located
#lxcpath=$(lxc-config lxc.lxcpath)
#rootfs=$(lxc-info -n "$container" -c lxc.rootfs.path|rev|cut -d " " -f 1|cut -d ":" -f 1|rev)
#containerpath=$(echo "$lxcpath""/""$container")

#Now we customize the network interface configuration and
#copy it to the right place inside the containers file system
cp "$script_dir"/interfaces "$script_dir"/interfaces.work
#sed -i "s/intmask/$intmask/g" "$script_dir"/interfaces.work
#sed -i "s/intaddress/$intaddress/g" "$script_dir"/interfaces.work

#lxc file push "$script_dir"/interfaces.work "$container"/etc/network/interfaces
cp "$script_dir"/interfaces.work "$rootfs"/etc/network/interfaces

#activate forwarding
sed -i "s/#net.ipv4.ip_forward/net.ipv4.ip_forward/g" "$rootfs"/etc/sysctl.conf
sed -i "s/#net.ipv6.conf.all.forwarding/net.ipv6.conf.all.forwarding/g" "$rootfs"/etc/sysctl.conf

#copy scripts 
cp -a "$script_dir"/scripts "$rootfs"/home/ubuntu/

lxc-attach -n "$container" -- git clone https://github.com/thombashi/tcconfig /home/ubuntu/scripts/tcconfig
lxc-attach -n "$container" -- git clone https://github.com/urbenlegend/netimpair /home/ubuntu/scripts/netimpair
lxc-attach -n "$container" -- git clone https://github.com/Excentis/impairment-node /home/ubuntu/scripts/impairment-node

lxc-attach -n "$container" -- chown -R ubuntu:ubuntu /home/ubuntu/scripts

lxc-attach -n "$container" -- adduser ubuntu wireshark
lxc-attach -n "$container" -- bash -c "echo ubuntu:resu | chpasswd" 

#we restart the container to have the interfaces correctly configured
#at our disposition
lxc-stop -n "$container"
lxc-wait -n "$container" -s STOPPED
lxc-start -n "$container"
lxc-wait -n "$container" -s RUNNING

lxc-attach -n "$container" -- apt-get -y autoremove
lxc-attach -n "$container" -- apt-get clean

lxc-stop -n "$container"
lxc-wait -n "$container" -s STOPPED
lxc-start -n "$container"
lxc-wait -n "$container" -s RUNNING

#netplan: arghhh! We want ifupdown and so we need to get rid of 
#this junk!
lxc-attach -n "$container" -- apt-get -y remove netplan
lxc-attach -n "$container" -- rm -rf /etc/netplan

lxc-stop -n "$container"
lxc-wait -n "$container" -s STOPPED
lxc-start -n "$container"
lxc-wait -n "$container" -s RUNNING

ip link show "$controldev" | grep "state UP" > /dev/null
if [ $? -ne 0 ]
then
	echo "$controldev is not up (yet) - is this on purpose?"
fi
ip link show "$serverdev" | grep "state UP" > /dev/null
if [ $? -ne 0 ]
then
	echo "$serverdev is not up (yet) - is this on purpose?"
fi
ip link show "$consumerdev" | grep "state UP" > /dev/null
if [ $? -ne 0 ]
then
	echo "$consumerdev is not up (yet) - is this on purpose?"
fi
