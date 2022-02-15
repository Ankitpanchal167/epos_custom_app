#!/bin/bash

Path_Images=/home/root/Images/

LIST_FLASH_FILES=(
"/dev/mtd0,MLO"
"/dev/mtd4,am438x-epos.dtb"
"/dev/mtd5,u-boot.img"
"/dev/mtd8,zImage"
"/dev/mtd11,am438x-epos-rootfs.ubi"
)

flash_partition=0
# Flash all partitions
for linedata in "${LIST_FLASH_FILES[@]}"
do
    Partition=$(echo $linedata | cut -d "," -f 1)
    File=$(echo $linedata | cut -d "," -f 2)
    retry=0;

    if [ -f $Path_Images/$File ]
    then
        while [ $retry -lt 3 ];
        do
            let retry++

            flash_eraseall $Partition
            if [ $? -ne 0 ]
            then
                continue
            fi

            nandwrite -p  $Partition $Path_Images/$File
            if [ $? -eq 0 ];
            then
                break
            fi
        done
    fi

    if [ $retry -ge 3 ]
    then
        Error "Failed to flash <$File> to <$Partition>"
        flash_partition=1
        break;
    fi
done
[ $flash_partition -eq 1 ] && exit 1;

exit 0


