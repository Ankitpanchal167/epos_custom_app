#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

IMG_FOLDER=/home/root/test_logs/Images/
CAMERA_NODE=/dev/v4l/by-path/platform-48326000.vpfe-video-index0

camera_detect()
{
	if [ -e $CAMERA_NODE ]; then
		print_status "Main Camera Detect" "PASS"
	else
		print_status "Main Camera Detect" "FAIL"
		print_result 1
	fi
}

capture_photo_convert_raw_to_jpeg()
{
	v4l2-ctl --device $CAMERA_NODE --stream-mmap --stream-to=$IMG_FOLDER/MainCamera.yuv --stream-count=5 --stream-skip=25 >> /dev/null 2>&1
	if [ $? == 0 ]; then
		print_status "Capture Raw Image" "PASS"
	else
		print_status "Capture Raw Image" "FAIL"
		print_result 1
	fi

	ffmpeg -f rawvideo -vcodec rawvideo -s 640x480 -r 25 -pix_fmt yuyv422 -i $IMG_FOLDER/MainCamera.yuv  $IMG_FOLDER/MainCamera_%d.png -y >> /dev/null 2>&1
	if [ $? == 0 ]; then
		print_status "Convert Raw to JPEG Image" "PASS"
	else
		print_status "Convert Raw to JPEG Image" "FAIL"
		print_result 1
	fi

	# Display image on LCD
	echo 0 > /sys/class/graphics/fb0/blank
	/usr/bin/fbvs-master -d /dev/fb0 --stretch < $IMG_FOLDER/MainCamera_1.png
}

# Delete old data
mkdir -p $IMG_FOLDER
rm -rf $IMG_FOLDER/MainCamera*

# Clear LCD screen
/usr/bin/fb-test -w

# Detect controller on i2c
camera_detect
capture_photo_convert_raw_to_jpeg

# Copy image to SDcard or USB storage drive or network drive

# Display Result
printlog "Is Main Camera image proper? Press(y/N):\n"
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
