#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

i2c_addr="0x55"
i2c_bus=2

detect_fg()
{
	i2cdetect -r -y $i2c_bus > /dev/null
	ret=$?
	if [ $ret -ne 0 ]
	then
	    printlog "I2C Bus $i2c_bus is not initialized properly\n"
	    print_result 1
	fi

	ret=$(i2cdetect -r -y $i2c_bus | tail -n 3 | head -n 1 | awk ' {print $7}')
	if [ "0x$ret" == "$i2c_addr" ] || [ $ret == "UU" ]; then
	    print_status "Detect battery gauge" "PASS"
	else
	    print_status "Detect battery gauge" "FAIL"
	    print_result 1
	fi
}

read_voltage_temperature_and_soc()
{
	volt=$(cat /sys/class/power_supply/bq27510g3_battery/voltage_now)
	if [ "$volt" == "" ]; then
       		printlog "Failed to Read I2C Register\n"
        	printlog "Check if Battery is present and connected properly\n"
        	print_result 1
	fi
	volt_mV=`printf "%d uV\n" $volt`
	print_status "Battery Voltage" "$volt uV"

	# Read Battery Temperature from fuelGauge
	temp=$(cat /sys/class/power_supply/bq27510g3_battery/temp)
	if [ $temp -lt 0 ]; then
		printlog "Failed to Read I2C Register\n"
		printlog "Check if Battery is present and connected properly\n"
		print_result 1
	fi

	# Add decimal point before last digit of Temperature
	#temp=`echo $temp | sed 's/.$/.&/'`
	print_status "Battery Temperature" "$temp C"

	soc=$(cat /sys/class/power_supply/bq27510g3_battery/capacity)
	if [ "$soc" == "" ]; then
		printlog "Failed to Read I2C Register\n"
		printlog "Check if Battery is present and connected properly\n"
		print_result 1
	fi

	print_status "Battery SOC" "$soc %%"

}

# Step 1:- Detect fg on I2C
detect_fg

# Step 2:- Read voltage, temperature and soc register
read_voltage_temperature_and_soc
print_result 0
