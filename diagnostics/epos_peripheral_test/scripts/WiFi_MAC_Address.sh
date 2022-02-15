#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

EXAMPLE="AA000X"
CONFIGURATION="NOT_SET"
FILE_DATA=/etc/wifi_mac_addr.txt
CLEAR=1
EXIT_VAL=1
FILE_TMP_MAC_ADDR=/etc/tmp_wifi_mac_addr.txt
WLAN_INTF="wlan0"
ARGS=""
READ_DUMMY_OPTS=0

Set_Data()
{
	# Check for wlan0 node
	ret=""
	MAC_ADDR=""

	if [ -f $FILE_TMP_MAC_ADDR ];then
		ret=$(cat $FILE_TMP_MAC_ADDR)
	fi
	if [ -f $FILE_DATA ];then
		MAC_ADDR=$(cat $FILE_DATA)
	fi
	if [ "$ret" == "" ] || [ ! -f $FILE_TMP_MAC_ADDR ] || [ ! -f $FILE_DATA ] || [ -z $MAC_ADDR ];
	then
		ret=$(ifconfig -a | grep -cs $WLAN_INTF)
		if [ $ret -eq 1 ]
		then
			MAC_ADDR=$(ifconfig $WLAN_INTF | grep 'Link encap' | awk '{print $5}')
			echo -ne $MAC_ADDR > $FILE_DATA
			temp_mac=`cat $FILE_DATA | sed 's/://g'`
			echo -ne $temp_mac > $FILE_TMP_MAC_ADDR
			EXIT_VAL=0
		else
			echo -ne "\n$WLAN_INTF node not found\n"
		fi
	fi

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
