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
