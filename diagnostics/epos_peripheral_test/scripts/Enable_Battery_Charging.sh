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

toggle_charging()
{
	charging=0
	# Get current charging state
	is_charging=$(cat /sys/class/power_supply/bq25601-battery/status)
	if [ "$is_charging" == "Not charging" ] || [ "$is_charging" == "Discharging" ]
	then
		charging=1
	fi

	if [ $charging == "1" ];then
		print_status "Charging" "DISABLED"
		printlog "Enable charging. Press(y/N):\n"
	else
		print_status "Charging" "ENABLED"
		printlog "Disable charging. Press(y/N):\n"
	fi
	read ANS
	[ -z $ANS ] && ANS="N"

	# Enable Battery Charging
	if [ "$ANS" == "Y" ] || [ "$ANS" == "y" ]
	then
		echo $charging > /sys/class/power_supply/bq25601-battery/toggle_charging

		sleep 1

		charging=0
		# Get current charging state
		is_charging=$(cat /sys/class/power_supply/bq25601-battery/status)
		if [ "$is_charging" == "Not charging" ] || [ "$is_charging" == "Discharging" ]
		then
			charging=1
		fi

		if [ $charging == "1" ];then
			print_status "Charging" "DISABLED"
		else
			print_status "Charging" "ENABLED"
		fi
	fi
}

# Step 1:- Detect battery charger on I2C
battery_charger_detect

toggle_charging

print_result 0
