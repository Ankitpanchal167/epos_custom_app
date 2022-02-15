#!/bin/bash
STATUS_VAL_LIST=("PASS" "FAIL")
TEST_NAME=$(basename $0 | cut -d"." -f1)

printlog () { printf "$(date)\t$@" ; }
print_status () { printlog "$(printf "%-42s: %s" "$1" "$2")\n"; }
print_result()
{
	status=$1
	#printlog "##################################################\n"
	#print_status "$TEST_NAME" "${STATUS_VAL_LIST[$status]} #"
	#printlog "##################################################\n"

	exit $status
}

export_gpio()
{
	if [ $# -ne 1 ]; then
		echo "Invalid no. of arguments passed"
		return 1
	fi

	pin=$1
	if [ ! -d "/sys/class/gpio/gpio$pin" ]; then
		echo $pin > /sys/class/gpio/export
	fi
	echo out > /sys/class/gpio/gpio$pin/direction

	return 0
}

unexport_gpio()
{
	if [ $# -ne 1 ]; then
		echo "Invalid no. of arguments passed"
		return 1
	fi

	pin=$1
	if [ -d "/sys/class/gpio/gpio$pin" ]; then
		echo $pin > /sys/class/gpio/unexport
	fi
	return 0
}

Display_Menu_Header()
{
	COLUMNS=53

        echo -e  "
++++++++++++++++++++++++++++++++++++++++++++++++++++"

title="$PRODUCT_NAME Peripheral Test v$DIAG_VERSION"
printf "%*s\n" $(((${#title}+$COLUMNS)/2)) "$title"

title="$1"
printf "%*s" $(((${#title}+$COLUMNS)/2)) "$title"

        echo -e "
++++++++++++++++++++++++++++++++++++++++++++++++++++"
}

Display_Temp_Screen()
{
	exit_loop1=0
	while [ 1 ]; do
		if [ $exit_loop1 -eq 1 ]; then
			return 0
			break
		fi

		if [ "$1" != "View configurations" ]; then
			echo -e "\n$1: $OPT saved"
		fi

		if [ $READ_DUMMY_OPTS -eq 1 ];then
			break
		fi

		echo -e "\nPress any key to continue..."
		read OPT
		exit_loop1=1
	done
}
