#!/bin/bash

printlog () { printf "$(date)\t$@" ; }
Thm_FOLDER=/home/root/thermal
mkdir -p $Thm_FOLDER

trigger_barcode()
{
	stty -icanon -F /dev/ttyS3
	while read line; do
		NOW=$(date '+%d_%m_%Y_%H_%M_%S')
		echo ${NOW} >> ${Thm_FOLDER}/barcodelog
		echo $line >> ${Thm_FOLDER}/barcodelog
		echo $line
		# Read data from serial and put in temporary file
		if [ "$line" != "" ];then
			echo -n "$line"
		fi

		# Stop Barcode
		if [ -f /tmp/loadstoptest ]
		then
			break
		fi
	done < /dev/ttyS3

	printlog "Exiting Barcode test"
}

LCD_RGB_test()
{
	echo 0 > /sys/class/graphics/fb0/blank
	while [ ! -f /tmp/loadstoptest ];
	do
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

	printlog "Exiting Main LCD test"
}

MainCamera()
{
	local cnt=0
	while [ ! -f /tmp/loadstoptest ];
	do
		let "cnt++"
		NOW=$(date '+%d_%m_%Y_%H_%M_%S')
		v4l2-ctl --device /dev/video0 --stream-mmap --stream-to=${Thm_FOLDER}/ov7740_frame.yuv --stream-count=50 --stream-skip=25
		ffmpeg -f rawvideo -vcodec rawvideo -s 640x480 -r 25 -pix_fmt yuyv422 -i ${Thm_FOLDER}/ov7740_frame.yuv  ${Thm_FOLDER}/Main_${cnt}_${NOW}_%d.jpg
		sleep 1
	done

	printlog "Exiting Main Camera test"
}

IRISCamera()
{
	local cnt=0
	echo 0 > /sys/class/backlight/backlight/bl_power #on
	echo 8 > /sys/class/backlight/backlight/brightness #max brightness

	while [ ! -f /tmp/loadstoptest ];
	do
		let "cnt++"
		NOW=$(date '+%d_%m_%Y_%H_%M_%S')
		v4l2-ctl --device /dev/video1 --stream-mmap --stream-to=${Thm_FOLDER}/ov7725_frame.yuv --stream-count=50 --stream-skip=25
		ffmpeg -f rawvideo -vcodec rawvideo -s 640x480 -r 25 -pix_fmt yuyv422 -i ${Thm_FOLDER}/ov7725_frame.yuv  ${Thm_FOLDER}/Iris_${cnt}_${NOW}_%d.jpg
		sleep 1
	done

	printlog "Exiting IRIS Camera test"
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

	printlog "Exiting Audio test"
}

gauge()
{
	while [ ! -f /tmp/loadstoptest ];
	do
		cat /sys/class/power_supply/bq27510g3_battery/voltage_now
		cat /sys/class/power_supply/bq27510g3_battery/temp
		cat /sys/class/power_supply/bq27510g3_battery/capacity

		date >> ${Thm_FOLDER}/log
		NOW=$(date '+%d_%m_%Y_%H_%M_%S')
		echo ${NOW} >> ${Thm_FOLDER}/log
		cat /sys/class/power_supply/bq27510g3_battery/voltage_now >> ${Thm_FOLDER}/log
		cat /sys/class/power_supply/bq27510g3_battery/temp >> ${Thm_FOLDER}/log
		cat /sys/class/power_supply/bq27510g3_battery/capacity >> ${Thm_FOLDER}/log

		sleep 1
	done

	printlog "Exiting Fuel gauge test"
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
		NOW=$(date '+%d_%m_%Y_%H_%M_%S')
		echo ${NOW} >> ${Thm_FOLDER}/btlog
		hcitool scan >> ${Thm_FOLDER}/btlog
		hcitool scan
		sleep 1
	done

	printlog "Exiting Bluetooth test"
}

wifiscan()
{
	ifconfig wlan0 up
	sleep 3

	while [ ! -f /tmp/loadstoptest ];
	do
		iw wlan0 scan
		NOW=$(date '+%d_%m_%Y_%H_%M_%S')
		echo ${NOW} >> ${Thm_FOLDER}/wifilog
		iw wlan0 scan  >> ${Thm_FOLDER}/wifilog
		sleep 5
	done

	#wpa_supplicant -i wlan0 -c /etc/wpa_supplicant.conf -B
	#sleep 1
	#udhcpc -i wlan0

	#ping 10.100.129.157

	printlog "Exiting WIFI test"
}

fingerprint_scan()
{
	cnt=0
	while [ ! -f /tmp/loadstoptest ];
	do
		let "cnt++"
		NOW=$(date '+%d_%m_%Y_%H_%M_%S')
		/usr/bin/fingerprint_app -s 100000 -D /dev/spidev2.0
		ffmpeg -f rawvideo -vcodec rawvideo -s 256x360 -r 1 -pix_fmt gray -i test.yuv ${Thm_FOLDER}/FingerPrint_${cnt}_${NOW}.jpg > /dev/null 2>&1
		sleep 1
	done

	printlog "Exiting Fingerprint test"
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

	printlog "Exiting Barcode test"
}

charger_reg_read()
{
	while [ ! -f /tmp/loadstoptest ];
	do
		i2cget -f -y 2 0x6b 0x00 >> /dev/null 2>&1
		i2cget -f -y 2 0x6b 0x01 >> /dev/null 2>&1
		i2cget -f -y 2 0x6b 0x02 >> /dev/null 2>&1
		i2cget -f -y 2 0x6b 0x03 >> /dev/null 2>&1
		i2cget -f -y 2 0x6b 0x04 >> /dev/null 2>&1
		i2cget -f -y 2 0x6b 0x05 >> /dev/null 2>&1
		i2cget -f -y 2 0x6b 0x06 >> /dev/null 2>&1
		i2cget -f -y 2 0x6b 0x07 >> /dev/null 2>&1
		i2cget -f -y 2 0x6b 0x08 >> /dev/null 2>&1
		i2cget -f -y 2 0x6b 0x09 >> /dev/null 2>&1
		i2cget -f -y 2 0x6b 0x0A >> /dev/null 2>&1
		i2cget -f -y 2 0x6b 0x0B >> /dev/null 2>&1
		sleep 1
	done

	printlog "Exiting Charger test"
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

	printlog "Exiting OLED test"
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
	trigger_barcode &
	barcode_scan &
fi

wait

sleep 3
exit 0
