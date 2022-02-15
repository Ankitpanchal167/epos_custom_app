#!/bin/bash

printlog () { printf "$(date)\t$@" ; }



LCD_RGB_test()
{
	echo 0 > /sys/class/graphics/fb0/blank
	while [ ! -f /tmp/loadstoptest ];
	do
		echo "LCD test stop flag $StopTest"
		fb-test -f 0
		sleep 1
		fb-test -r
		sleep 1
		fb-test -g
		sleep 1
		fb-test -b
		sleep 1
		fb-test -w
		sleep 1
	done
}

MainCamera()
{
	while [ ! -f /tmp/loadstoptest ];
	do
		v4l2-ctl --device /dev/video0 --stream-mmap --stream-to=ov7740_frame.yuv --stream-count=50 --stream-skip=25
		sleep 1
	done
}

IRISCamera()
{
	echo 0 > /sys/class/backlight/backlight/bl_power #on
	echo 8 > /sys/class/backlight/backlight/brightness #max brightness

	while [ ! -f /tmp/loadstoptest ];
	do
		v4l2-ctl --device /dev/video0 --stream-mmap --stream-to=ov7740_frame.yuv --stream-count=50 --stream-skip=25
		sleep 1
	done
}

AudioPlay()
{
	amixer -c 0 cset iface=MIXER,name="HP Driver Playback Switch" 1
	amixer -c 0 cset iface=MIXER,name="DAC Left Input" 1
	amixer -c 0 cset iface=MIXER,name="DAC Right Input" 1
	amixer -c 0 cset iface=MIXER,name="HP Analog Playback Volume" 60
	amixer -c 0 cset iface=MIXER,name="HP Driver Playback Volume" 3
	amixer -c 0 cset iface=MIXER,name="HP Left Switch" 1
	amixer -c 0 cset iface=MIXER,name="HP Right Switch" 1
	amixer -c 0 cset iface=MIXER,name="Output Left From Left DAC" 1
	amixer -c 0 cset iface=MIXER,name="Output Right From Right DAC"  1
	amixer -c 0 cset iface=MIXER,name="DAC Playback Volume" 127
	amixer -c 0 cset iface=MIXER,name="Speaker Switch"  1
	amixer -c 0 cset iface=MIXER,name="Speaker Left Switch" 1
	amixer -c 0 cset iface=MIXER,name="Speaker Driver Playback Switch" 1
	amixer -c 0 cset iface=MIXER,name="DAC Playback Volume"  150
	amixer -c 0 cset iface=MIXER,name="Speaker Analog Playback Volume"  74
	amixer -c 0 cset iface=MIXER,name="Speaker Driver Playback Volume" 3
	sleep 1

	while [ ! -f /tmp/loadstoptest ];
	do
		aplay /usr/share/sounds/alsa/Front_Center.wav
		sleep 1
	done
}

gauge()
{
	while [ ! -f /tmp/loadstoptest ];
	do
		cat /sys/class/power_supply/bq27510g3_battery/voltage_now
		cat /sys/class/power_supply/bq27510g3_battery/temp
		cat /sys/class/power_supply/bq27510g3_battery/capacity
		sleep 1
	done
}

btscan()
{

	if [ ! -f /tmp/btattched ]; then
		echo 104 > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio104/direction
		echo 0 > /sys/class/gpio/gpio104/value #reset bt reg
		sleep 1
		echo 1 > /sys/class/gpio/gpio104/value #bt reg on
		hciattach -s 115200 /dev/ttyO1 texas
		if [ $? -eq 0 ]; then
			touch /tmp/btattched
		fi
		sleep 3
	fi

	while [ ! -f /tmp/loadstoptest ];
	do
		hcitool scan
		sleep 1
	done
}

wifiscan()
{
	ifconfig wlan0 up
	sleep 3
	wpa_supplicant -i wlan0 -c /etc/wpa_supplicant.conf -B
	sleep 1
        udhcpc -i wlan0

	ping 10.100.129.157
}

fingerprint_scan()
{
	while [ ! -f /tmp/loadstoptest ];
	do
		/usr/bin/fingerprint_app -s 100000 -D /dev/spidev2.0
		sleep 1
	done
}

barcode_scan()
{
	echo 161 > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio161/direction
	sleep 1

	while [ ! -f /tmp/loadstoptest ];
	do
		echo 0 > /sys/class/gpio/gpio161/value
		sleep 1
		echo 1 > /sys/class/gpio/gpio161/value
		sleep 1
	done
}

charger_reg_read()
{
	while [ ! -f /tmp/loadstoptest ];
	do
		echo "charger top flag $StopTest"
		i2cget -f -y 2 0x6b 0x00
		i2cget -f -y 2 0x6b 0x01
		i2cget -f -y 2 0x6b 0x02
		i2cget -f -y 2 0x6b 0x03
		i2cget -f -y 2 0x6b 0x04
		i2cget -f -y 2 0x6b 0x05
		i2cget -f -y 2 0x6b 0x06
		i2cget -f -y 2 0x6b 0x07
		i2cget -f -y 2 0x6b 0x08
		i2cget -f -y 2 0x6b 0x09
		i2cget -f -y 2 0x6b 0x0A
		i2cget -f -y 2 0x6b 0x0B
		sleep 1
	done
}

OLED()
{
	spi_node="/dev/spidev4.0"

	if [ ! -f /sys/class/gpio/gpio49 ]
	then
		echo 49 > /sys/class/gpio/export
		echo out > /sys/class/gpio/gpio49/direction
	fi

	while [ ! -f /tmp/loadstoptest ];
	do
		/usr/bin/oled_app -s 1000000 -D $spi_node -S "00000.00"; sleep 1; if [ ! -f /tmp/loadstoptest ];then break;fi
		/usr/bin/oled_app -s 1000000 -D $spi_node -S "11111.11"; sleep 1; if [ ! -f /tmp/loadstoptest ];then break;fi
		/usr/bin/oled_app -s 1000000 -D $spi_node -S "22222.22"; sleep 1; if [ ! -f /tmp/loadstoptest ];then break;fi
		/usr/bin/oled_app -s 1000000 -D $spi_node -S "33333.33"; sleep 1; if [ ! -f /tmp/loadstoptest ];then break;fi
		/usr/bin/oled_app -s 1000000 -D $spi_node -S "44444.44"; sleep 1; if [ ! -f /tmp/loadstoptest ];then break;fi
		/usr/bin/oled_app -s 1000000 -D $spi_node -S "55555.55"; sleep 1; if [ ! -f /tmp/loadstoptest ];then break;fi
		/usr/bin/oled_app -s 1000000 -D $spi_node -S "66666.66"; sleep 1; if [ ! -f /tmp/loadstoptest ];then break;fi
		/usr/bin/oled_app -s 1000000 -D $spi_node -S "77777.77"; sleep 1; if [ ! -f /tmp/loadstoptest ];then break;fi
		/usr/bin/oled_app -s 1000000 -D $spi_node -S "88888.88"; sleep 1; if [ ! -f /tmp/loadstoptest ];then break;fi
		/usr/bin/oled_app -s 1000000 -D $spi_node -S "99999.99"; sleep 1; if [ ! -f /tmp/loadstoptest ];then break;fi
	done
}


if [ -f /tmp/loadstoptest ]; then
	rm /tmp/loadstoptest
fi

trap "touch /tmp/loadstoptest;echo 1 > /sys/class/graphics/fb0/blank" SIGHUP SIGINT SIGTERM

TestMainCamera=0
printlog "Test Main Camera: (y/N)\n"
read ANS

[ -z $ANS ] && ANS="Y"
if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	TestMainCamera=1
fi

TestIRISCamera=0
printlog "Test IRIS Camera: (y/N)\n"
read ANS

[ -z $ANS ] && ANS="Y"
if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	TestIRISCamera=1
fi

TestMainLCD=0
printlog "Test Main LCD: (y/N)\n"
read ANS

[ -z $ANS ] && ANS="Y"
if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	TestMainLCD=1
fi

TestAudio=0
printlog "Test Audio: (y/N)\n"
read ANS

[ -z $ANS ] && ANS="Y"
if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	TestAudio=1
fi

Testgauge=0
printlog "Test Gauge: (y/N)\n"
read ANS

[ -z $ANS ] && ANS="Y"
if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	Testgauge=1
fi

TestCharger=0
printlog "Test Charger: (y/N)\n"
read ANS

[ -z $ANS ] && ANS="Y"
if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	TestCharger=1
fi

TestBT=0
printlog "Test Bluetooth : (y/N)\n"
read ANS

[ -z $ANS ] && ANS="Y"
if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	TestBT=1
fi

TestWIFI=0
printlog "Test Wi-Fi : (y/N)\n"
read ANS

[ -z $ANS ] && ANS="Y"
if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	TestWIFI=1
fi

TestFP=0
printlog "Test Finger Print : (y/N)\n"
read ANS

[ -z $ANS ] && ANS="Y"
if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	TestFP=1
fi

TestOLED=0
printlog "Test OLED : (y/N)\n"
read ANS

[ -z $ANS ] && ANS="Y"
if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	TestOLED=1
fi

TestBarcode=0
printlog "Test Barcode : (y/N)\n"
read ANS

[ -z $ANS ] && ANS="Y"
if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	TestBarcode=1
fi


# Camera Color
if [ $TestMainCamera == 1 ];then
	MainCamera &
fi

# Camera IRIS
if [ $TestIRISCamera == 1 ];then
	IRISCamera &
fi

# LCD
if [ $TestMainLCD == 1 ];then
	LCD_RGB_test &
fi

# Audio
if [ $TestAudio == 1 ];then
	AudioPlay &
fi

# Battery gauge
if [ $Testgauge == 1 ];then
	gauge &
fi

# BT
if [ $TestBT == 1 ];then
	btscan &
fi

# WIFI
if [ $TestWIFI == 1 ];then
	wifiscan &
fi

# Fingerprint
if [ $TestFP == 1 ];then
	fingerprint_scan &
fi

# Charger
if [ $TestCharger == 1 ];then
	charger_reg_read &
fi

# OLED test
if [ $TestOLED == 1 ];then
	OLED &
fi

# Barcode test
if [ $TestBarcode == 1 ];then
	barcode_scan &
fi

wait

sleep 3
exit 0
