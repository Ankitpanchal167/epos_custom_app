#!/bin/bash
source /opt/epos_peripheral_test/scripts/common.sh

spi_node=/dev/spidev4.0

spi_node_detect()
{
	if [ -e $spi_node ]; then
		printlog "SPI Bus 1 is initialized\n"
	else
		printlog "SPI Bus 1 is not initialized properly\n"
		print_result 1
	fi
}

reset_oled()
{
	export_gpio 1
	echo 0 > /sys/class/gpio/gpio1/value
	sleep 1
	echo 1 > /sys/class/gpio/gpio1/value
	export_gpio 49
	echo 1 > /sys/class/gpio/gpio49/value
	print_status "Device reset" "PASS"
}

display_pattern()
{
	/usr/bin/oled_app -s 1000000 -D $spi_node -S "00000.00" >> /dev/null; sleep 1
	/usr/bin/oled_app -s 1000000 -D $spi_node -S "11111.11" >> /dev/null; sleep 1
	/usr/bin/oled_app -s 1000000 -D $spi_node -S "22222.22" >> /dev/null; sleep 1
	/usr/bin/oled_app -s 1000000 -D $spi_node -S "33333.33" >> /dev/null; sleep 1
	/usr/bin/oled_app -s 1000000 -D $spi_node -S "44444.44" >> /dev/null; sleep 1
	/usr/bin/oled_app -s 1000000 -D $spi_node -S "55555.55" >> /dev/null; sleep 1
	/usr/bin/oled_app -s 1000000 -D $spi_node -S "66666.66" >> /dev/null; sleep 1
	/usr/bin/oled_app -s 1000000 -D $spi_node -S "77777.77" >> /dev/null; sleep 1
	/usr/bin/oled_app -s 1000000 -D $spi_node -S "88888.88" >> /dev/null; sleep 1
	/usr/bin/oled_app -s 1000000 -D $spi_node -S "99999.99" >> /dev/null; sleep 1
}

spi_node_detect

reset_oled

display_pattern

# Display Result
printlog "Is OLED display working? Press(y/N):\n"
read ANS
[ -z $ANS ] && ANS="N"

# Turn off OLED display
/usr/bin/oled_app -s 1000000 -D $spi_node -x  >> /dev/null 2>&1

if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	print_status "OLED display test" "PASS"
else
	print_status "OLED display test" "FAIL"
	print_result 1
fi
print_result 0
