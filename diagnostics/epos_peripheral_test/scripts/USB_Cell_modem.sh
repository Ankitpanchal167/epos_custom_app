#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

WEBSITE="www.google.com"

pppd call airtel &
is_interface_active=$(ifconfig -a | grep 'ppp0' | wc -l)
if [ "$is_interface_active" == "1" ];then
	print_status "PPP interface" "Active"
else
	print_status "PPP interface" "Not Active"
	print_result 1
fi

ip_addr=$(ifconfig ppp0 | grep 'inet addr' | awk '{print $2}' | cut -d ':' -f 2)
print_status "IP address" "$ip_addr"

ping -c 3 www.google.com > /tmp/ping.out
print_status "Ping address" "$WEBSITE"

packet_loss=$(cat /tmp/ping.out | grep "packet loss" | awk '{print $6}' | tr -d '[:alpha:]')
print_status "Ping packet loss" "$packet_loss %"

if [ "$packet_loss" -gt "30" ];
then
	print_result 1
fi
print_result 0

