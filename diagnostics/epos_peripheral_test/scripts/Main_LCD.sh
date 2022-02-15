#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

display_rgb()
{
	ret=" "
	ret=$(ls /dev/ | grep -i fb0)
	if [ "$ret" == "fb0" ]; then
		print_status "Detect Display node" "PASS"
	else
		print_status "Detect Display node" "FAIL"
		print_fail
	fi

	echo 0 > /sys/class/graphics/fb0/blank
	fb-test -f 0 >> /dev/null
	if [ $? == 0 ]; then
		print_status "Display RGB" "PASS"
	else
		print_status "Display RGB" "FAIL"
		print_result 1
	fi

}

display_result()
{
	printlog "Is Main LCD working? Press(y/N):\n"
	read ANS
	echo 1 > /sys/class/graphics/fb0/blank
	[ -z $ANS ] && ANS="N"
	if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
		print_status "Main LCD display" "PASS"
		print_result 0
	else
		print_status "Main LCD display" "FAIL"
		print_result 1
	fi
}

display_rgb

# Display Result
display_result
