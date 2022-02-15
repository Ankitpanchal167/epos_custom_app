#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

EXAMPLE=""
CONFIGURATION="NOT_SET"
MAX_LENGHT=20
FILE_DATA=/etc/te_name.txt
CLEAR=0
EXIT_VAL=1
ARGS=""
READ_DUMMY_OPTS=0

Display()
{
	echo -ne "\nEnter Test Engineer's Name : "
}

Validate()
{
    val=$1

	if [ -z "$val" ]
	then
	   	echo -e "\nPlease enter valid data\n";
		return 1;
	fi

    if [ $(echo $val | wc -c) -gt $MAX_LENGHT ];then
        echo -e "\nPlease enter valid data\n";
        return 1
    fi

    echo "$val" | grep -v "^[a-zA-Z0-9]*$" >> /dev/null
    if [ $? -eq 0 ];then
        echo -e "\nPlease enter valid data\n";
        return 1
    fi

	return 0
}

Set_Data()
{
	count=0
	exit_loop=0
	temp=""

	[ "$CLEAR" == 1 ] && clear

	if [ "$CONFIGURATION" == "SET" ]; then
		if [ -f $FILE_DATA ]; then
			temp=`cat $FILE_DATA`
			echo -e "Serial Number already set to $temp"
		fi
	fi

	Display
	if [ "$READ_DUMMY_OPTS" == "1" ];then
		OPT=$ARGS
	else
		read OPT
		if [ "$temp" != "" ] && [ "$OPT" == "" ];then
			OPT=$temp
		fi
	fi

	# Validate Serial Number
	Validate "$OPT"
	ret=$?
	if [ $ret -eq 0 ];then
		CONFIGURATION="SET"
		echo -ne "$OPT" > $FILE_DATA
		sync
		EXIT_VAL=0
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
