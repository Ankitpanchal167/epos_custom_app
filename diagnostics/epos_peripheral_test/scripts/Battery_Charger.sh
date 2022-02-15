#!/bin/bash
source /opt/epos_peripheral_test/scripts/common.sh
i2c_addr="0x6b"
i2c_bus=2

battery_charger_detect()
{
	i2cdetect -r -y $i2c_bus > /dev/null
	ret=$?
	if [ "$ret" != "0" ]; then
		printlog "I2C Bus $i2c_bus is not initialized properly\n"
		print_result 1
	fi

	ret=" "
	ret=$(i2cdetect -r -y $i2c_bus | tail -n 2 | head -n 1 | awk ' {print$13} ')
	if [ "0x$ret" == "$i2c_addr" ] || [ "$ret" == "UU" ]; then
		print_status "Detect battery charger" "PASS"
	else
		print_status "Detect battery charger" "FAIL"
		print_result 1
	fi
}

detect_charger()
{
	count=0
	charger_source=""
	volt=""
	charger_connect=0

	# Check battery presence
	#volt=$(i2cget -f -y 4 0x55 0x08 w) >> /dev/null 2>&1
	#if [ "$volt" == "" ]; then
	#    printlog "Check if Battery is present and connected properly\n"
	#	print_result 1
	#fi

	# Enable Battery Charging
	echo 1 > /sys/class/power_supply/bq25601-battery/toggle_charging

	printlog "Connect charger within 20 seconds\n"
	while [ $count -lt 20 ]; do
		ret1=$(i2cget -f -y $i2c_bus $i2c_addr 0x08)
		ret1=$(( $ret1 & 0x18 ))
		if [ "$ret1" != "0" ]
		then
			charger_connect=1
			charger_source=$(cat /sys/class/power_supply/bq25601-charger/type)
			if [ "$charger_source" == "Mains" ]; then
				print_status "Battery charging status" "PASS"
				break
			else
				print_status "Battery charging status" "FAIL"
				printlog "Invalid charger detected <$charger_source>\n"
				print_result 1
			fi
		fi
		sleep 1
		let count++
	done

	if [ $charger_connect -eq 0 ];then
		print_status "Battery charging status" "FAIL"
		printlog "No charger detected <$charger_source>\n"
	fi
}

# Step 1:- Detect battery charger on I2C
battery_charger_detect

detect_charger
print_result 0
