#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

timer=20
if [ -f /etc/sw_poweroff ]
then
	rm /etc/sw_poweroff
	sync

	printlog "Is software poweroff working (y/N)? \n"
	read ANS

	[ -z $ANS ] && ANS="N"

	if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
		print_status "S/w Poweroff Test" "PASS"
		print_result 0
	else
		print_status "S/w Poweroff Test" "FAIL"
		print_result 1
	fi
fi

touch /etc/sw_poweroff
sync
# Execute poweroff command
poweroff

while [ $timer -gt 0 ]
do
	let timer--
	sleep 1
done

print_result 1
