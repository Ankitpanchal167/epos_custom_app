#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

printlog "Is Hardware poweron working (y/N)? \n"
read ANS

[ -z $ANS ] && ANS="N"

if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
	print_status "H/w Poweron Test" "PASS"
	print_result 0
else
	print_status "H/w Poweron Test" "FAIL"
	print_result 1
fi
