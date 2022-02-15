#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

MinVal=960280
proc_mem=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')

print_status "DDR Memory Size" "$proc_mem KB"
if [ "$proc_mem" -ge "$MinVal" ];then
	print_result 0
else
	print_result 1
fi
