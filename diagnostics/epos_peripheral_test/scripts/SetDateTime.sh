#!/bin/bash
major=`cat /proc/devices | grep pub2sec | cut -d" " -f1`
mknod /dev/pub2sec c $major 0 2>&1 >>/dev/null

TIME_STAMP=$1
if [ "$TIME_STAMP" == "" ];then
	exit 1
fi
DIAG_BIN_DIR=/usr/bin/

cd $DIAG_BIN_DIR
./rtcTime "$1" >> /dev/null
ret=$?
exit $ret
