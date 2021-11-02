#!/bin/bash

# Optional parameters
# $1 is the WslSubnetPrefix which defaults to "192.168.50"
# $2 is the WslHostIP which defaults to "$WslSubnetPrefix.2"
# $3 is the GatewayIP which defaults to "$WslSubnetPrefix.1"

WslSubnetPrefix="$(if [ -n "$1" ];then echo $1; else echo "192.168.50"; fi)"
WslHostIP="$(if [ -n "$2" ];then echo $2; else echo "$WslSubnetPrefix.2"; fi)"
GatewayIP="$(if [ -n "$3" ];then echo $3; else echo "$WslSubnetPrefix.1"; fi)"
echo Booting $(hostname -s) with WslSubnetPrefix=$WslSubnetPrefix, WslHostIP=$WslHostIP, GatewayIP=$GatewayIP ...

# Debug logging
log=/var/log/wsl-boot.log
mkdir -p $(dirname $log)
currentIP=$(ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | head -n 1)
echo "Original IP = $currentIP" >$log

# Run this script as root at boot to set static IP
ip addr del $currentIP dev eth0
ip addr add $WslHostIP/24 broadcast $WslSubnetPrefix.255 dev eth0
ip route add 0.0.0.0/0 via $GatewayIP dev eth0

# Start services
service ssh start
#service cron start

# Check configuration
echo WslHostIP = $(hostname -I)
grep nameserver /etc/resolv.conf
