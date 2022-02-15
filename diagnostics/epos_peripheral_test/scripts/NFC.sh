#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

rm /tmp/nfc_card_detect
rm /tmp/nfc_card_uuid

python /opt/epos_peripheral_test/scripts/PN7462/test_script.py

if [ -f "/tmp/nfc_card_detect" ];then
	print_status "NFC card" "Detected"
else
	print_status "NFC card" "Not detected"
	print_result 1
fi

UUID=$(cat /tmp/nfc_card_uuid)
[ -z "$UUID" ] && UUID=0

print_status "NFC card UUID" "$UUID"

print_result 0
