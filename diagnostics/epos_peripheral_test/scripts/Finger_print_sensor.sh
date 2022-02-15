#!/bin/bash
source /opt/epos_peripheral_test/scripts/common.sh

fp_spi_node=/dev/spidev2.0
IMG_FOLDER=/home/root/test_logs/Images/

spi_node_detect()
{
	if [ -e $fp_spi_node ]; then
		printlog "SPI Bus 1 is initialized\n"
	else
		printlog "SPI Bus 1 is not initialized properly\n"
		print_result 1
	fi
}

capture_fp_image_convert_raw_to_jpeg()
{
	printlog "Put finger on FP sensor and Press (Y/n):\n"
	read ANS

	[ -z $ANS ] && ANS="Y"

	if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
		/usr/bin/fingerprint_app -s 1000000 -D $fp_spi_node
		if [ $? == 0 ]; then
			print_status "Capture Raw Image" "PASS"
		else
			print_status "Capture Raw Image" "FAIL"
			print_result 1
		fi
	else
		print_result 1
	fi

	mv test.yuv $IMG_FOLDER/fp.yuv
	ffmpeg -f rawvideo -vcodec rawvideo -s 256x360 -r 1 -pix_fmt gray -i $IMG_FOLDER/fp.yuv $IMG_FOLDER/FingerPrint.png -y > /dev/null 2>&1
	if [ $? == 0 ]; then
		print_status "Convert raw to jpeg image" "PASS"
	else
		print_status "Convert raw to jpeg image" "FAIL"
		print_result 1
	fi

	# Display image on LCD
	echo 0 > /sys/class/graphics/fb0/blank
	/usr/bin/fbvs-master -d /dev/fb0 --stretch < $IMG_FOLDER/FingerPrint.png
}

# Delete old data
mkdir -p $IMG_FOLDER
rm -f $IMG_FOLDER/fp.yuv $IMG_FOLDER/FingerPrint.jpg

# Clear LCD screen
/usr/bin/fb-test -w

# Detect spi dev node
spi_node_detect

capture_fp_image_convert_raw_to_jpeg

# Copy image to SDcard or USB storage drive

# Display Result
printlog "Is fingerprint image proper? Press(y/N):\n"
read ANS
[ -z $ANS ] && ANS="N"

/usr/bin/fb-test -w
echo 1 > /sys/class/graphics/fb0/blank

if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
    print_status "Image quality" "PASS"
else
    print_status "Image quality" "FAIL"
    print_result 1
fi

print_result 0
