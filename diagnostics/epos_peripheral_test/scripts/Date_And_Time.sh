#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

EXAMPLE="DD-MM-YYYY HH:MM:SS"
CONFIGURATION_DATE_TIME="NOT_SET"
FILE_CONFIG_RTC=/etc/config_rtc.txt
CLEAR=1
ARGS=""
READ_DUMMY_OPTS=0

Display_Set_DateTime()
{
	echo -ne "\nEnter Date and Time [YYYY-MM-DD HH:MM:SS]:

	Enter: "
}

Menu_Set_DateTime()
{
	if [ "$CONFIGURATION_DATE_TIME" == "SET" ]; then
		echo -e "Current date and time is $(date '+%Y-%m-%d %H:%M:%S')"
	fi

	Display_Set_DateTime

	if [ "$READ_DUMMY_OPTS" == "1" ];then
		OPT="$ARGS"
	else
		read OPT
	fi

	if [ "$OPT" != "" ];then
		# Set Time on RTC and device
		date -s "$OPT" && /bin/bash /opt/epos_peripheral_test/scripts/SetDateTime.sh "$OPT"
		if [ $? -eq 0  ]; then
			CONFIGURATION_DATE_TIME=1
			date +'%Y/%m/%d %H:%M:%S' > $FILE_CONFIG_RTC
		fi
	fi
}

Get_DateTime()
{
	# Check Serial Config Files
	TIME=""
	if [ -f $FILE_CONFIG_RTC ];then
		TIME=$(cat $FILE_CONFIG_RTC)
	fi
	echo $TIME

}

Check_DateTime()
{
	CONFIGURATION_DATE_TIME="NOT_SET"
	# Check Serial Config Files
	if [ -f $FILE_CONFIG_RTC ];then
		CONFIGURATION_DATE_TIME="SET"
	fi
	echo $CONFIGURATION_DATE_TIME
}

while [ "$1" != "" ]; do
	case $1 in
		--check)
			shift
			Check_DateTime
			;;
		--get)
			shift
			Get_DateTime
			;;
		--set)
			shift
			ARGS="$1"
			if [ ! -z $ARGS ] && [ "$ARGS" != "NULL" ]
			then
				READ_DUMMY_OPTS=1
			fi
			Menu_Set_DateTime
			;;
	esac
	shift
done
