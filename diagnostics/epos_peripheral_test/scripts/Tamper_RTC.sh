#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

# Read Current date
cur_time_sec=$(date +%s)

# Read time from Tamper RTC
print_status "System Time" "$(date +'%Y-%m-%d %H:%M:%S')"
timestamp=$(cd /usr/bin/ && /usr/bin/rtcTime | grep "Date:YEAR=" -A 2 | tail -n 1)
ret=$?
if [ $ret -eq 0 ]
then
	print_status "Read Tamper RTC" "PASS"
else
	print_status "Read Tamper RTC" "FAIL"
	print_result 1
fi

time_sec=$(date -d "$timestamp" +%s)
diff=$(($cur_time_sec - $time_sec))

if [ $diff -lt 0 ];then
	diff=${diff#-}
fi
# Compare time
print_status "RTC Time" "$timestamp"
print_status "Time difference" "$(($time_sec - $cur_time_sec))s"
if [ $diff -gt 60 ]
then
	print_result 1
fi

print_result 0
