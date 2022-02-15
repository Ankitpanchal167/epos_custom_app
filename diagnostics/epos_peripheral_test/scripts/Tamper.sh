#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

printlog "Is Tamper protection working (y/N)? \n"
read ANS

[ -z $ANS ] && ANS="N"

if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	print_status "Tamper Test" "PASS"
else
	print_status "Tamper Test" "FAIL"
	print_result 1
fi

print_result 0
