#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

PRODUCT="EPOS"

Set_Product_Description()
{
	echo $PRODUCT
}

Get_Product_Description()
{
	echo $PRODUCT
}

Check_Product_Description()
{
	echo "SET"
}

while [ "$1" != "" ]; do
	case $1 in
		--check)
			Check_Product_Description
			shift
			;;
		--get)
			shift
			Get_Product_Description
			;;
		--set)
			shift
			;;
	esac
	shift
done

exit 0
