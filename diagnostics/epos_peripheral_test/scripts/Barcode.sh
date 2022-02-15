#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

VALUE="001122334455"
TRIG=161 #nTRIG
export_gpio $TRIG

trigger_barcode()
{
	stty -icanon -F /dev/ttyS3
	while read line; do
		echo $line
		# Read data from serial and put in temporary file
		if [ "$line" != "" ];then
			echo -n "$line" > /tmp/barcode_data
		fi

		# Stop Barcode
		if [ -f /tmp/stop_barcode ]
		then
			break
		fi
	done < /dev/ttyS3
}

barcode_scan()
{
    while [ ! -f /tmp/stop_barcode ];
    do
		# Trigger by toggling GPIO
		echo 0 > /sys/class/gpio/gpio$TRIG/value #on
		sleep 1
		echo 1 > /sys/class/gpio/gpio$TRIG/value #off
		sleep 1
	done
}

rm -f /tmp/stop_barcode
echo "" > /tmp/barcode_data
barcode_scan &
trigger_barcode &
pid=$!
timeout=10

while [ $timeout -gt 0 ];
do
	sleep 1
	val=$(cat /tmp/barcode_data)

	# Ignore blank reads
	if [ "$val" == "" ];then
		let timeout--
		continue
	fi

	print_status "Barcode read" "<$val>"

	if [ "$val" == "$VALUE" ];
	then
		print_status "Barcode read" "PASS"
		touch /tmp/stop_barcode
		kill -9 $pid >> /dev/null
		print_result 0
		break
	fi

	if [ "$val" != "" ];
	then
		printlog "Is value correct? (y/N):\n"
		echo 1 > /sys/class/gpio/gpio$TRIG/value #off
		sleep 1
		read ANS
		[ -z $ANS ] && ANS="N"

		touch /tmp/stop_barcode
		kill -9 $pid >> /dev/null
		if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
			print_status "Barcode read" "PASS"
			print_result 0
		else
			print_status "Barcode read" "FAIL"
			print_result 1
		fi
		break
	fi

	let timeout--
done

kill -9 $pid >> /dev/null
touch /tmp/stop_barcode
print_status "Barcode read" "FAIL"
print_result 1
