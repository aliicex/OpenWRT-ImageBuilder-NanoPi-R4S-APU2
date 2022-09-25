#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

/usr/local/opt/dnsmasq/sbin/dnsmasq stop

dnspid=$(pgrep dnsmasq)

echo "DNSMASQ PID = " $dnspid

if [[ $dnspid != "" ]]; then
  kill $dnspid 
fi

currentDir=`pwd`
echo "Current Dir: "$currentDir
echo "Selected interface: "$1

ifconfig $1 down && ifconfig $1 192.168.10.1 up
/usr/local/opt/dnsmasq/sbin/dnsmasq -i $1 --dhcp-range=192.168.10.100,192.168.10.200 \
--dhcp-boot=openwrt-22.03.0-ipq40xx-mikrotik-mikrotik_hap-ac2-initramfs-kernel.bin \
--enable-tftp --tftp-root=$currentDir -d -u root -p0 -K --log-dhcp --bootp-dynamic