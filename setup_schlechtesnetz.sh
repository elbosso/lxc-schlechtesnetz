#!/bin/bash
script=${0}
script_dir=`dirname $script`

#config variables from command line arguments
container=${1}
controldev=${2}
consumerdev=${3}
serverdev=${4}

echo "operating from within ${script_dir}"

echo "building container ${container}..."

lxc-info -n ${container}
if [ $? -eq 0 ]
then
        echo "container already there - aborting!"
        exit 1
fi

#lxc-create for the container - at this moment, we always build a bionic beaver ubuntu container
lxc-create -t download -n ${container} -- -d ubuntu -r bionic  -a amd64

lxc-info -n ${container}
if [ $? -ne 0 ]
then
        echo "container creation failed - aborting!"
        exit 2
fi

#changing the config of the container so it has the interfaces named
#at startup properly assigned
sed -i "s/lxc.net.0.link =.*/lxc.net.0.link = ${controldev}/g" /var/lib/lxc/${container}/config
echo "lxc.net.1.type = veth" >> /var/lib/lxc/${container}/config 
echo "lxc.net.1.link = ${consumerdev}" >> /var/lib/lxc/${container}/config
echo "lxc.net.1.flags = up" >> /var/lib/lxc/${container}/config
echo "lxc.net.2.type = veth" >> /var/lib/lxc/${container}/config 
echo "lxc.net.2.link = ${serverdev}" >> /var/lib/lxc/${container}/config
echo "lxc.net.2.flags = up" >> /var/lib/lxc/${container}/config

#starting the container
lxc-start -n ${container}
lxc-wait -n ${container} -s RUNNING

#netplan: arghhh! We want ifupdown and so we need to get rid of 
#this junk!
lxc-attach -n ${container} -- apt-get -y remove netplan

#Now we install ll needed packages
#(or some the author deems necessary...)
lxc-attach -n ${container} -- apt-get update
lxc-attach -n ${container} -- apt-get -y upgrade
lxc-attach -n ${container} -- apt-get -y install joe screen conky ifupdown openssh-server bridge-utils

#Because we do not use or require LXD at this point,
#we can not use lxc push file
#so we have to cp files and to be able to do so - we
#need to know where the root file system of the container is located
lxcpath=`lxc-config lxc.lxcpath`
rootfs=`lxc-info -n ${container} -c lxc.rootfs.path|rev|cut -d " " -f 1|cut -d ":" -f 1|rev`
containerpath=`echo ${lxcpath}"/"${container}`

#Now we customize the network interface configuration and
#copy it to the right place inside the containers file system
cp ${script_dir}/interfaces ${script_dir}/interfaces.work
sed -i "s/intmask/${intmask}/g" ${script_dir}/interfaces.work
sed -i "s/intaddress/${intaddress}/g" ${script_dir}/interfaces.work

#lxc file push ${script_dir}/interfaces.work ${container}/etc/network/interfaces
cp ${script_dir}/interfaces.work ${rootfs}/etc/network/interfaces

#we restart the container to have the interfaces correctly configured
#at our disposition
lxc-stop -n ${container}
lxc-wait -n ${container} -s STOPPED
lxc-start -n ${container}
lxc-wait -n ${container} -s RUNNING

lxc-attach -n ${container} -- apt-get -y autoremove
lxc-attach -n ${container} -- apt-get clean

lxc-stop -n ${container}
lxc-wait -n ${container} -s STOPPED
lxc-start -n ${container}


