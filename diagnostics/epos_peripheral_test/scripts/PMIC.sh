#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

i2c_addr="0x24"
i2c_bus=0

pmic_detect()
{
	i2cdetect -r -y $i2c_bus > /dev/null
	ret=$?
	if [ "$ret" != "0" ]; then
		printlog "I2C Bus $i2c_bus is not initialized properly\n"
		print_result 1

	fi

	ret=$(i2cdetect -r -y 0 | tail -n 6 | head -n 1 | awk ' {print$6} ')
	if [ "0x$ret" == "$i2c_addr" ] || [ "$ret" == "UU" ]; then
		print_status "Detect PMIC on I2C" "PASS"
	else
		printlog "Detect PMIC on I2C" "FAIL"
		print_result 1
	fi
}


REG_LIST=(
"0x00,0x05"
"0x01,0x00"
"0x02,0x00"
"0x03,0x37"
"0x04,0x3f"
#"0x05,0x8b"
"0x06,0x02"
"0x07,0x00"
"0x08,0x00"
"0x09,0x00"
"0x0A,0x00"
"0x0B,0x00"
"0x0C,0x00"
"0x0D,0x00"
"0x0E,0x00"
"0x0f,0x00"
"0x10,0x00"
"0x11,0x3f"
"0x12,0x1b"
"0x13,0xcc"
"0x14,0x4a"
"0x15,0x00"
"0x16,0x99"
"0x17,0x8a"
"0x18,0x92"
"0x19,0xb2"
"0x1A,0x06"
"0x1B,0x1f"
"0x1C,0x00"
"0x1D,0x00"
"0x1E,0x00"
"0x1f,0x00"
"0x20,0x00"
"0x21,0x00"
"0x22,0x98"
"0x23,0x70"
"0x24,0x12"
"0x25,0x63"
"0x26,0x00"
)

read_and_validate_registers()
{
	error=0
	for reg_val in ${REG_LIST[@]}
	do
		reg=$(echo $reg_val | cut -d ',' -f 1)
		val=$(echo $reg_val | cut -d ',' -f 2)

		reg_sys=`i2cget -f -y $i2c_bus $i2c_addr $reg`
		if [ $? -ne 0 ]; then
			printlog "Failed to read REGISTER $reg\n"
			error=1
		fi
		if [ "$reg_sys" != "$val" ]; then
			printlog "Wrong configuration for $reg. Found <$reg_sys> instead of <$val>\n"
			error=1
		fi
	done

	if [ "$error" -eq 1 ]
	then
		print_result 1
	else
		print_status "Register check" "PASS"
	fi
}

# Step 1:- Detect PMIC on I2C
pmic_detect

# Read pmic registers and validate the results
read_and_validate_registers
print_result 0
