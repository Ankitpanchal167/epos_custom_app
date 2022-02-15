#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

timer=20

if [ -f /etc/sw_reboot ];then
	rm /etc/sw_reboot
	sync

	printlog "Is software reboot working (y/N)? \n"
	read ANS

	[ -z $ANS ] && ANS="N"

	if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
		print_result 0
	else
		print_result 1
	fi

fi

touch /etc/sw_reboot
sync
# Execute reboot command
reboot

while [ $timer -gt 0 ]
do
	let timer--
	sleep 1
done

print_result 1
