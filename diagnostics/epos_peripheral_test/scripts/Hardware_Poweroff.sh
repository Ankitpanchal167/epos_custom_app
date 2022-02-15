#!/bin/bash
source /opt/epos_peripheral_test/scripts/common.sh

timer=20

if [ -f /etc/hw_poweroff ]
then
	rm /etc/hw_poweroff
	sync

	printlog "Is Hardware poweroff working (y/N)? \n"
	read ANS

	[ -z $ANS ] && ANS="N"

	if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
		print_status "H/w Poweroff Test" "PASS"
		print_result 0
	else
		printlog "H/w Poweroff Test" "FAIL"
		print_result 1
	fi
fi

touch /etc/hw_poweroff
sync
# Ask user to press "X" button for 5s
printlog "Press 'X' button for 5 seconds\n"

while [ $timer -gt 0 ]
do
	let timer++
	sleep 1
done

printlog "H/w Poweroff Test" "FAIL"
print_result 1

