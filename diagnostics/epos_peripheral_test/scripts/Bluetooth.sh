#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

BT_SCAN_DEVICE="EPOSBTTEST"
reset_gpio=104

reset_bt_controller()
{
	export_gpio $reset_gpio
	echo 0 > /sys/class/gpio/gpio$reset_gpio/value
	sleep 1
	echo 1 > /sys/class/gpio/gpio$reset_gpio/value
}

check_hci_node()
{
	ret=$(hciconfig | grep -cs "hci0")
	if [ $ret -ne 1 ]
	then
	    print_status "Detect BT module" "FAIL"
	    print_result 1
	else
	    print_status "Detect BT module" "PASS"
	fi
}

configure_bt()
{
	#hciconfig hci0 up
	#usleep 5000
	echo "SERIAL=$serial"
	hciconfig hci0 name 'EPOS_'$serial
	hciconfig hci0 piscan
	hciconfig hci0 sspmode 1
	print_status "Bluetooth module initialization" "PASS"
}

scan_bt_devices()
{
	#hciconfig hci0 up
	#sleep 1
	hcitool scan > /tmp/detected_bt_devices
	address=$(cat /tmp/detected_bt_devices | grep -w "$BT_SCAN_DEVICE" | sed -e 's/\t/ /g' | cut -d ' ' -f 2)
	if [ "$address" == "" ]; then
		print_status "Bluetooth Scan" "FAIL"
		print_result 1
	fi
	print_status "Connected device MAC" "$address"
	print_status "Bluetooth Scan" "PASS"
	print_result 0
}

# Step 1:- Reset BT controller
if [ ! -f /tmp/bt_attach ];then
	touch /tmp/bt_attach
	reset_bt_controller
	sleep 3
	# Step 2:- Initialize hci0
	hciattach -s 115200 /dev/ttyS1 texas
	sleep 1
	hciconfig hci0 up
fi

# Step 3:- Check for hci0 node
check_hci_node

scan_bt_devices

# Step 4:- Configure BT
#configure_bt
