#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

TMP_MTD_DATA=/tmp/mtd_data
TMP_PROC_DATA=/tmp/proc_mtd_data

cat << EOF > $TMP_MTD_DATA
dev:    size   erasesize  name
mtd0: 00040000 00020000 "NAND.SPL"
mtd1: 00040000 00020000 "NAND.SPL.backup1"
mtd2: 00040000 00020000 "NAND.SPL.backup2"
mtd3: 00040000 00020000 "NAND.SPL.backup3"
mtd4: 00080000 00020000 "NAND.u-boot-spl-os"
mtd5: 00100000 00020000 "NAND.u-boot"
mtd6: 00040000 00020000 "NAND.u-boot-env"
mtd7: 00040000 00020000 "NAND.u-boot-env.backup1"
mtd8: 00700000 00020000 "NAND.kernel"
mtd9: 00100000 00020000 "NAND.u-boot-spl-os2"
mtd10: 00700000 00020000 "NAND.kernel2"
mtd11: 14e00000 00020000 "NAND.file-system"
mtd12: 0a000000 00020000 "NAND.file-system2"
EOF

# Read from procfs
cat /proc/mtd > $TMP_PROC_DATA

lines_of_diff=$(diff $TMP_MTD_DATA $TMP_PROC_DATA | wc -l)
if [ "$lines_of_diff" != "0" ]
then
	print_result 1
fi

num_partition=$(cat $TMP_PROC_DATA | grep 'mtd' | wc -l)
partition=$(cat $TMP_PROC_DATA | grep 'mtd' | awk '{print $NF}' | tr '\n' ' ')
print_status "Total Partitions" "$num_partition"
print_status "NAND partitions" "$partition"

print_result 0
