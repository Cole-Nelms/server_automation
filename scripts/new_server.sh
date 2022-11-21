

#----------------------------------------------------------------------
#
#  This script installs packages, and
#  sets static ethernet ip address for
#  new servers.
#
#  It expects two arguments. The first is
#  the ip address of the server, and the
#  second is the default gateway of the network.
#
#  Be sure to run this command logged in as root. If
#  you use sudo be sure to pass the --set-home
#  option, or python may not install docker
#  system wide.
#
#----------------------------------------------------------------------


#!/bin/bash

# Install required packages.
#----------------------------------------------------------------------

apt update

PACKAGES=(
  "python3"
  "python3-pip"
  "python3-apt"
  "aptitude"
)

for i in ${!PACKAGES[@]}; do
  apt install ${PACKAGES[$i]} -y
done

pip install docker

# Set static ip address on ethernet.
#----------------------------------------------------------------------

ETH=$(ip link | awk -F: '$0 !~ "lo|vir|wl|^[^0-9]"{print $2;getline}')
ETH=$(echo ${ETH} | sed -e 's/^[[:space:]]*//')

echo "
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

allow-hotplug ${ETH}
iface ${ETH} inet static
      address ${1}
      netmask 255.255.255.0
      gateway ${2}
" > /etc/network/interfaces

echo "
nameserver ${2}
nameserver 8.8.8.8
nameserver 8.8.4.4
" > /etc/resolv.conf
