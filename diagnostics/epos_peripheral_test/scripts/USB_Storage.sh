#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

MOUNT_POINT=/mnt/sd
SAMPLE_FILE=/tmp/sd_test
STORAGE_NODE="/dev/disk/by-path/usb-part1"
STR="USB"

storage_detect()
{
	if [ -e "$STORAGE_NODE" ];then
		print_status "Detect $STR storage" "PASS"
	else
		print_status "Detect $STR storage" "FAIL"
		print_result 1
	fi
}

write_to_storage_verify()
{
	touch $SAMPLE_FILE
	f_name=$(basename $SAMPLE_FILE)

	mkdir -p $MOUNT_POINT
	mount $STORAGE_NODE $MOUNT_POINT
	if [ $? == 0 ]; then
		print_status "$STR storage Mount" "PASS"
	else
		print_status "$STR storage Mount" "FAIL"
		print_result 1
	fi

	# Copy sample file to external storage
	cp $SAMPLE_FILE $MOUNT_POINT

	local_file=$(md5sum $SAMPLE_FILE | awk '{print $1}')
	copied_file=$(md5sum $MOUNT_POINT/$f_name | awk '{print $1}')

	rm -rf $SAMPLE_FILE
	rm -rf $MOUNT_POINT/$f_name
	umount $MOUNT_POINT
	rm -rf $MOUNT_POINT
	if [ "$local_file" != "$copied_file" ]; then
		print_status "Write data to $STR" "FAIL"
		print_result 1
	else
		print_status "Write data to $STR" "PASS"
	fi
}

mkdir -p $MOUNT_POINT
# Detect USB storage detect
storage_detect

write_to_storage_verify
print_result 0
