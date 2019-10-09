# lxc-schlechtesnetz

<!---
[![start with why](https://img.shields.io/badge/start%20with-why%3F-brightgreen.svg?style=flat)](http://www.ted.com/talks/simon_sinek_how_great_leaders_inspire_action)
--->
[![GitHub release](https://img.shields.io/github/release/elbosso/lxc-schlechtesnetz/all.svg?maxAge=1)](https://GitHub.com/elbosso/lxc-schlechtesnetz/releases/)
[![GitHub tag](https://img.shields.io/github/tag/elbosso/lxc-schlechtesnetz.svg)](https://GitHub.com/elbosso/lxc-schlechtesnetz/tags/)
[![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![GitHub license](https://img.shields.io/github/license/elbosso/lxc-schlechtesnetz.svg)](https://github.com/elbosso/lxc-schlechtesnetz/blob/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/elbosso/lxc-schlechtesnetz.svg)](https://GitHub.com/elbosso/lxc-schlechtesnetz/issues/)
[![GitHub issues-closed](https://img.shields.io/github/issues-closed/elbosso/lxc-schlechtesnetz.svg)](https://GitHub.com/elbosso/lxc-schlechtesnetz/issues?q=is%3Aissue+is%3Aclosed)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/elbosso/lxc-schlechtesnetz/issues)
[![GitHub contributors](https://img.shields.io/github/contributors/elbosso/lxc-schlechtesnetz.svg)](https://GitHub.com/elbosso/lxc-schlechtesnetz/graphs/contributors/)
[![Github All Releases](https://img.shields.io/github/downloads/elbosso/lxc-schlechtesnetz/total.svg)](https://github.com/elbosso/lxc-schlechtesnetz)
[![Website elbosso.github.io](https://img.shields.io/website-up-down-green-red/https/elbosso.github.io.svg)](https://elbosso.github.io/)

This project holds scripts for setting up and using a container to emulate various 
connection cheracteristics using netem. Kind of like docker scripts but without docker.

## Preconditions

This script has been extensively tested on the latest long term support version of Ubuntu - this being 18.04. When trying to use it on other distributions or flavours there may be incompatibilities or other problems, prohibiting productive use.

The server that is going to host the resulting appliances must have linux-bridges available. On Ubuntu and derivates this can be achieved by installing the package named bridge-utils by issuing for example `sudo apt install bridge-utils`. 

The server that is going to host the resulting appliances should also have IPv4-Forwarding enabled. This can be achieved either by issuing `echo 1 > /proc/sys/net/ipv4/ip_forward` or `sysctl -w net.ipv4.ip_forward=1` but this change will be gone after the next boot. To make this change persistent, edit _/etc/sysctl.conf_ and change the value of `net.ipv4.ip_forward = 1`. To read the current state of affairs, one can issue either `sysctl net.ipv4.ip_forward` or `cat /proc/sys/net/ipv4/ip_forward`.

As a router appliance needs to be connected to two bridges it is necessary to create them. This can be done by issuing `brctl addbr <name_of_bridge>`. This however is only good until after the next reboot. Another possibility - and one that is persistent and survives the next reboot - is to append the following snippet to _/etc/network/interfaces_  for each bridge needed:

```
auto <name_of_bridge>
iface <name_of_bridge> inet dhcp
  bridge_ports none
```

Of course, one has to get rid of *netplan* and install *ifupdown* before this can work.

The safest bet is to call `service networking restart` afterwards to activate the changes

## setup_schlechtesnetz.sh

This script sets up a LXC container that can act as an intelligent piece of
network cabling with adjustable quality parameters. It has several command line parameters. Their meaning is as follows:

```
./setup_schlechtesnetz.sh <container> <controldev> <consumerdev> <serverdev> 
```
<dl>
  <dt>container</dt><dd>The name of the container to be created</dd>
  <dt>controldev</dt><dd>The name of the device on the host for controlling the configuration. The container opens a SSH server for connection on this interface.</dd>
  <dt>consumerdev</dt><dd>The name of the device one end of the intelligent network cable is attached to.</dd>
  <dt>serverdev</dt><dd>The name of the device the other  end of the intelligent network cable is attached to.</dd>
</dl>

## scripts

The scripts contained herein are available inside the container once it is built. The path inside the container is /scripts.
There are scripts for switching on several prebuilt profiles and of course one to switch it off. Furthermore, there is one script as template
for situations where only certain protocols or sockets should be influenced

A SSH-server is installed and active on this appliance.

Additionally, no password is set for the default user account named ubuntu.
If the user wants to use the console or SSH to login, some administrator has
to set a password for this account first (or create entirely new accounts of
course).
