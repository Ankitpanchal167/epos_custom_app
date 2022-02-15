#!/bin/bash
source /opt/epos_peripheral_test/scripts/common.sh

DEV_NODE=/dev/input/by-path/platform-4802a000.i2c-event
i2c_addr="0x34"
i2c_bus=1
rm -rf /tmp/StopKeyDetect /tmp/AllKeyDetect

declare -a KEY_LIST

KEY_LIST[0]="KEY_F1"
KEY_LIST[1]="KEY_CENTER"
KEY_LIST[2]="KEY_F2"
KEY_LIST[3]="KEY_1"
KEY_LIST[4]="KEY_2"
KEY_LIST[5]="KEY_3"
KEY_LIST[6]="KEY_4"
KEY_LIST[7]="KEY_5"
KEY_LIST[8]="KEY_6"
KEY_LIST[9]="KEY_7"
KEY_LIST[10]="KEY_8"
KEY_LIST[11]="KEY_9"
KEY_LIST[12]="KEY_*"
KEY_LIST[13]="KEY_0"
KEY_LIST[14]="KEY_X"
KEY_LIST[15]="KEY_ENTER"
KEY_LIST[16]="KEY_SPACE"

keypad_controller_detect()
{
	i2cdetect -r -y $i2c_bus > /dev/null
	ret=$?
	if [ "$ret" != "0" ]; then
		printlog "I2C Bus 1 is not initialized properly\n"
		print_result 1
	fi

	ret=" "
	ret=$(i2cdetect -r -y 1 | tail -n 5 | head -n 1 | awk ' {print$6} ')
	if [ "0x$ret" == "$i2c_addr" ] || [ "$ret" == "UU" ]; then
		print_status "Keypad Controller Detect" "PASS"
	else
		print_status "Keypad Controller Detect" "FAIL"
		print_result 1
	fi
}

detect_all_keys()
{
	ALL_KEYS_DETECTED=0

	evtest "$DEV_NODE" | while read line; do
		key_val=$(echo $line | grep 'value 1' | cut -d '(' -f3 | cut -d ')' -f1)
		case "$key_val" in
			"KEY_F1")      KEY_LIST[0]="0";;
			"KEY_SELECT")  KEY_LIST[1]="0";;
			"KEY_F2")      KEY_LIST[2]="0";;
			"KEY_1")       KEY_LIST[3]="0";;
			"KEY_2")       KEY_LIST[4]="0";;
			"KEY_3")       KEY_LIST[5]="0";;
			"KEY_4")       KEY_LIST[6]="0";;
			"KEY_5")       KEY_LIST[7]="0";;
			"KEY_6")       KEY_LIST[8]="0";;
			"KEY_7")       KEY_LIST[9]="0";;
			"KEY_8")       KEY_LIST[10]="0";;
			"KEY_9")		KEY_LIST[11]="0";;
			"KEY_NUMERIC_STAR")  	KEY_LIST[12]="0";;
			"KEY_0") 		KEY_LIST[13]="0";;
			"KEY_ENTER")		KEY_LIST[14]="0";;
			"SW_KEYPAD_SLIDE")	KEY_LIST[15]="0";;
			"KEY_SPACE")		KEY_LIST[16]="0";;
		esac

		# Print which all keys are pending
		if [ "$key_val" != "" ];then
			echo -ne "\r\nPending Keys: "
			ALL_KEYS_DETECTED=1
			for val in ${KEY_LIST[@]}; do
				if [ "$val" != "0" ]
				then
					ALL_KEYS_DETECTED=0
					echo -ne "$val, "
				fi
			done
		fi

		if [ $ALL_KEYS_DETECTED -eq 1 ]
		then
			touch /tmp/AllKeyDetect /tmp/StopKeyDetect
		fi

		if [ -f /tmp/StopKeyDetect ]
		then
			break;
		fi
	done

}

# Detect controller on i2c
keypad_controller_detect

printlog "Press every key on Keypad\n"
detect_all_keys &

printlog "Test will auto stop in 60s\n"
timeout=60
while [ $timeout -gt 0 ]
do
	if [ -f /tmp/AllKeyDetect ];then
		break
	fi
	sleep 1
	let timeout--
done

touch /tmp/StopKeyDetect
killall evtest

if [ -f /tmp/AllKeyDetect ]; then
	print_status "Keypad test" "PASS"
	print_result 0
else
	print_status "Keypad test" "FAIL"
	print_result 1
fi
