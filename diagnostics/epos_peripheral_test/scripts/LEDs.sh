#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

red_led_gpio=16
green_led_gpio=28
orange_led_gpio=29
yellow_led_gpio=21
fp_sensor_led_gpio=62

export_gpio()
{
    pin=$1
    if [ ! -d /sys/class/gpio/gpio$pin/ ]; then
        echo $pin > /sys/class/gpio/export
    fi
    echo out > /sys/class/gpio/gpio$pin/direction
    echo 0 > /sys/class/gpio/gpio$pin/value
    return 0
}

unexport_gpio()
{
    pin=$1
    if [ -d /sys/class/gpio/gpio$pin/ ]; then
       echo $pin > /sys/class/gpio/unexport
    fi
    return 0
}


set_all_leds_on()
{
	echo 1 > /sys/class/gpio/gpio$red_led_gpio/value
	print_status "Red LED" "ON"

	echo 1 > /sys/class/gpio/gpio$green_led_gpio/value
	print_status "Green LED" "ON"

	echo 1 > /sys/class/gpio/gpio$orange_led_gpio/value
	print_status "Orange LED" "ON"

	echo 1 > /sys/class/gpio/gpio$yellow_led_gpio/value
	print_status "Yellow LED" "ON"

	echo 1 > /sys/class/gpio/gpio$fp_sensor_led_gpio/value
	print_status "Fingerprint LED" "ON"
}

set_all_leds_off()
{
	echo 0 > /sys/class/gpio/gpio$red_led_gpio/value
	echo 0 > /sys/class/gpio/gpio$green_led_gpio/value
	echo 0 > /sys/class/gpio/gpio$orange_led_gpio/value
	echo 0 > /sys/class/gpio/gpio$yellow_led_gpio/value
	echo 0 > /sys/class/gpio/gpio$fp_sensor_led_gpio/value
}

# Configure led gpio
export_gpio $red_led_gpio
export_gpio $green_led_gpio
export_gpio $orange_led_gpio
export_gpio $yellow_led_gpio
export_gpio $fp_sensor_led_gpio

# All LEDs on
set_all_leds_on

# Display Result
printlog "Are LEDs Working Properly? Press(y/N):\n"
read ANS
[ -z $ANS ] && ANS="N"

set_all_leds_off
#unexport_gpio $red_led_gpio
#unexport_gpio $green_led_gpio
#unexport_gpio $orange_led_gpio
#unexport_gpio $yellow_led_gpio
#unexport_gpio $fp_sensor_led_gpio
if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	print_status "Led test" "PASS"
	print_result 0
else
	print_status "Led test" "FAIL"
	print_result 1
fi
