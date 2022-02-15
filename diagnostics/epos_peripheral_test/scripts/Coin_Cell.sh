#!/bin/bash
source /opt/epos_peripheral_test/scripts/common.sh

# Triggers voltage acquisition. Bit is automatically reset to 0
i2cset -y -f 0 0x24 0x06 0x3

sleep 2
# Read status from PMIC
retVal=$(i2cget -y -f 0 0x24 0x05)

# 0h = VCC < VLOW_LEVEL; Coin cell is not present or approaching endof-life (EOL)
# 1h = VLOW_LEVEL < VCC < VGOOD_LEVEL; Coin cell voltage is LOW.
# 2h = VGOOD_LEVEL < VCC <VIDEAL_LEVEL; Coin cell voltage is GOOD.
# 3h = VIDEAL < VCC; Coin cell voltage is IDEAL.

r=$(( ($retVal & 0x03) != 0 ))
if [ $r -eq 1 ];then
	print_status "Coin Cell detect" "PASS"
else
	print_status "Coin Cell detect" "FAIL"
	print_result 1
fi

print_result 0

