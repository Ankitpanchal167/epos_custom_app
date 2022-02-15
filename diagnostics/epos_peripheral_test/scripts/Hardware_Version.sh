#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

HW_VERSION="ALPHA"

Set_Hardware_Version()
{
	echo $HW_VERSION
}

Get_Hardware_Version()
{
	echo $HW_VERSION
}

Check_Hardware_Version()
{
	echo "SET"
}

while [ "$1" != "" ]; do
	case $1 in
		--check)
			Check_Hardware_Version
			shift
			;;
		--get)
			shift
			Get_Hardware_Version
			;;
		--set)
			shift
			;;
	esac
	shift
done

exit 0
