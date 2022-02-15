#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

string_2P4Ghz="EPOSWIFITEST_2.4"
pass_bit=0
WPA_SUPPLICANT_CONF="/opt/epos_peripheral_test/configs/wpa_supplicant.conf"

# Step 1:- Check for wlan0 node
ret=$(ifconfig -a | grep -cs "wlan0")
if [ $ret -eq 0 ]
then
    print_status "Detect Wifi module" "FAIL"
    print_result 1
else
    print_status "Detect Wifi module" "PASS"
fi

ifconfig wlan0 up
iw dev wlan0 scan | grep "SSID" | grep -w "$string_2P4Ghz" >> /dev/null
if [ $? -eq 0 ];  then
    print_status "WiFi 2.4GHz SSID Scan" "PASS"
else
    print_status "WiFi 2.4GHz SSID Scan" "FAIL"
    print_result 1
fi

# Step 3:- connect with 2.4GHz band.
#sed -i 's/ssid=.*/ssid='\"$string_2P4Ghz\"'/g' $WPA_SUPPLICANT_CONF
wpa_supplicant -i wlan0 -c $WPA_SUPPLICANT_CONF -B >> /dev/null 2>&1
udhcpc -i wlan0  >> /dev/null 2>&1
timer=15
while [ $timer -ge 0 ]; do
	ip="$(ifconfig | grep -A 1 "wlan0" | grep -A 1 "inet addr" | awk '{print $2}' | cut -d ':' -f 2)"
	if [ "defined$ip" != defined ]; then
		print_status "WiFi 2.4GHz Connection Test" "PASS"
		pass_bit=1
		break
	fi
	sleep 1
	let "timer--"
done

if [ $pass_bit -eq 0 ]; then
	print_status "WiFi 2.4GHz Connection Test" "FAIL"
	print_result 1
fi
print_result 0

