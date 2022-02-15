#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

EXAMPLE="AA000X"
CONFIGURATION="NOT_SET"
FILE_DATA=/etc/bsp_version.txt
EXIT_VAL=1
ARGS=""
READ_DUMMY_OPTS=0

Set_Data()
{
	# Value
	if [ -f $FILE_DATA ]
	then
		EXIT_VAL=0
	fi
	# Check for wlan0 node

}

Get_Data()
{
	VALUE=""
	# Check Serial Config Files
	if [ -f $FILE_DATA ];then
		VALUE=$(cat $FILE_DATA)
	fi
	echo $VALUE

}

Check()
{
	CONFIGURATION="NOT_SET"
	if [ -f $FILE_DATA ];then
		CONFIGURATION="SET"
	fi
	echo $CONFIGURATION
}

while [ "$1" != "" ]; do
	case $1 in
		--check)
			shift
			Check
			;;
		--get)
			shift
			Get_Data
			;;
		--set)
			shift
			ARGS="$1"
			if [ ! -z $ARGS ] && [ "$ARGS" != "NULL" ]
			then
				READ_DUMMY_OPTS=1
			fi
			Set_Data
			;;
	esac
	shift
done

exit $EXIT_VAL
