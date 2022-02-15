#!/bin/bash

FILE_NAME=$(basename $0)
#DIR_PREFIX="/home/jiju/Desktop/Theatro"
DIR_PREFIX=""
FILE_PKG_TGZ=
FILE_PKG_SEARCH_PATTERN=c3_firmware
FILE_PKG_NAME=
DIR_PKG_EXTRACT="$DIR_PREFIX/opt/downloads"
PARTITION_BOOTSTRAP=/dev/mtd0
PARTITION_UBOOT=/dev/mtd1
PARTITION_KERNELDTB=/dev/mtd4
PARTITION_KERNEL=/dev/mtd5
BACKUP_PKG=0
RETVAL_RESTORE_REQUIRED=2
RETVAL_RESTORE_NOTREQUIRED=1
RETVAL_SUCCESS=0

LIST_PKG_CRITICAL_FILES=(
"kernel/zImage"
"kernel/at91-sama5d2_com3.dtb"
"uboot/at91bootstrap.bin"
"drivers/kernel-module-gpio-wdt-4.9-r0.sama5d2_com3.rpm"
"drivers/kernel-module-pac193x-4.9-r0.sama5d2_com3.rpm"
"drivers/kernel-module-atmel-sama5d2-4.9-r0.sama5d2_com3.rpm"
"drivers/kernel-module-gauge-4.9-r0.sama5d2_com3.rpm"
"drivers/kernel-module-bmi160-core-4.9-r0.sama5d2_com3.rpm"
"drivers/kernel-module-bmi160-i2c-4.9-r0.sama5d2_com3.rpm"
"drivers/kernel-module-bq25601-4.9-r0.sama5d2_com3.rpm"
"drivers/kernel-module-rtc-pcf85363-4.9-r0.sama5d2_com3.rpm"
"drivers/kernel-module-leds-lp5562-4.9-r0.sama5d2_com3.rpm"
"drivers/kernel-module-leds-lp55xx-common-4.9-r0.sama5d2_com3.rpm"
"drivers/kernel-module-snd-soc-atmel-i2s-4.9-r0.sama5d2_com3.rpm"
"drivers/kernel-module-snd-soc-tlv320aic32x4-4.9-r0.sama5d2_com3.rpm"
"drivers/kernel-module-snd-soc-tlv320aic32x4-i2c-4.9-r0.sama5d2_com3.rpm"
"drivers/kernel-module-bq27z561-fg-4.9-r0.sama5d2_com3.rpm"
"drivers/kernel-module-lm75-4.9-r0.sama5d2_com3.rpm"
"drivers/backporttool-linux-1.0-r0.sama5d2_com3.rpm"
)

LIST_FLASH_FILES=(
"$PARTITION_BOOTSTRAP,uboot/at91bootstrap.bin"
"$PARTITION_UBOOT,uboot/u-boot.bin"
"$PARTITION_KERNELDTB,kernel/at91-sama5d2_com3.dtb"
"$PARTITION_KERNEL,kernel/zImage"
)

LIST_OLD_FW_DRIVERS=(
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/sound/soc/atmel/atmel-sama5d2.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/sound/soc/atmel/snd-soc-atmel_ssc_dai.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/sound/soc/atmel/snd-atmel-soc-pdmic.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/sound/soc/atmel/snd-soc-atmel-i2s.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/sound/soc/codecs/snd-soc-tlv320aic32x4-i2c.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/sound/soc/codecs/snd-soc-tlv320aic32x4.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/drivers/iio/adc/pac193x.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/drivers/iio/imu/bmi160/bmi160_core.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/drivers/iio/imu/bmi160/bmi160_i2c.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/drivers/rtc/rtc-pcf85363.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/drivers/leds/leds-blinkm.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/drivers/leds/leds-lp5562.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/drivers/leds/leds-regulator.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/drivers/leds/leds-lp55xx-common.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/drivers/watchdog/gpio_wdt.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/drivers/hwmon/lm75.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/drivers/power/supply/bq25601.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/drivers/power/supply/bq27z561_fg.ko"
"/lib/modules/4.9.87-linux4sam_5.8+/kernel/drivers/power/supply/gauge.ko"
"/etc/broadcom/wifi/compat.ko"
"/etc/broadcom/wifi/cfg80211.ko"
"/etc/broadcom/wifi/brcmutil.ko"
"/etc/broadcom/wifi/brcmfmac.ko"
)

#LIST_OLD_FW_FILES=(
#"/etc/enable_watchdog.sh"
#"/etc/init.d/broadcom"
#"/etc/udev/rules.d/99-input-event.rules"
#"/opt/create_symlink.sh"
#"/opt/remove_symlink.sh"
#"/opt/theatro/start_pppd.bash"
#"/usr/bin/upload_device_data"
#"/usr/bin/write_battery_serial"
#"/usr/bin/InternalAdc_test"
#"/usr/bin/Powermode_test"
#"/usr/bin/Tmp1075_test"
#"/usr/bin/Watchdog_test"
#"/usr/bin/audio_control_test"
#"/usr/bin/bleGattserver"
#"/usr/bin/ble_init"
#"/usr/bin/bmi_test"
#"/usr/bin/bt_init"
#"/usr/bin/charger_test"
#"/usr/bin/eeprom_test"
#"/usr/bin/fuel_gauge_test"
#"/usr/bin/i2c_test"
#"/usr/bin/interface_test"
#"/usr/bin/led_test"
#"/usr/bin/pac_test"
#"/usr/bin/peripheral_health_test"
#"/usr/bin/pmic_test"
#"/usr/bin/rfcomm-server"
#"/usr/bin/rtc_test"
#"/usr/bin/stopwatch_test"
#"/usr/lib/libinterface.so"
#"/etc/diagnostics.conf"
#"/root/c3_peripheral_test_2.0"
#"/usr/bin/shipping_mode"
#"/etc/c3_version/version_major"
#"/etc/c3_version/version_minor"
#"/usr/bin/version"
#"/etc/udev/rules.d/10-network.rules"
#"/lib/firmware/brcm/brcmfmac43455-sdio.bin"
#"/lib/firmware/brcm/brcmfmac43455-sdio.clm_blob"
#"/lib/firmware/brcm/brcmfmac43455-sdio.txt"
#"/usr/sbin/wl"
#"/etc/wpa_supplicant.conf"
#"/usr/sbin/wpa_supplicant_c3"
#)

Msg()
{
	#logger -p user.info -t $FILE_NAME "$*"
	echo "$*"
}
Error()
{
	#logger -p user.err -t $FILE_NAME "Error: $*"
	echo "Error: $*"
}
Notice()
{
	#logger -p user.notice -t $FILE_NAME "Notice: $*"
	echo "Notice: $*"
}

Exit () {
	if [ ! -z $FILE_PKG_NAME ] && [ -d $DIR_PKG_EXTRACT/$FILE_PKG_NAME ]
	then
		Msg "Deleting package folder: <$DIR_PKG_EXTRACT/$FILE_PKG_NAME>"
		rm -rf $DIR_PKG_EXTRACT/$FILE_PKG_NAME
	fi
	sync
	exit $1
}

Msg "Starting firmware update process"

# Create missing directories
mkdir -p $DIR_PKG_EXTRACT

while [ "$1" != "" ]; do
	case $1 in
		--tgzpath )
			shift
			FILE_PKG_TGZ=$1
			;;
		--backup )
			shift
			BACKUP_PKG=1
			;;
		*)
			Exit $RETVAL_RESTORE_NOTREQUIRED
	esac
	shift
done

Msg "Argument = <$FILE_PKG_TGZ>"

# Check if Package is available or not
if [ ! -f $FILE_PKG_TGZ ] || [ ! -f ${FILE_PKG_TGZ}.md5 ];
then
	Error "\"$FILE_PKG_TGZ\" or MD5sum file not found"
	Exit $RETVAL_RESTORE_NOTREQUIRED
fi

# Check if the tar file is valid
tar -t -f $FILE_PKG_TGZ >> /dev/null
if [ $? -ne 0 ]
then
	Error "\"$FILE_PKG_TGZ\" is not valid TAR archive"
	Exit $RETVAL_RESTORE_NOTREQUIRED
fi

# Extract package
tar -xzmf $FILE_PKG_TGZ -C $DIR_PKG_EXTRACT
if [ $? -ne 0 ];then
	Error "Failed to extract TAR acrhive <$FILE_PKG_TGZ>"
	Exit $RETVAL_RESTORE_NOTREQUIRED
fi

# Get the name of extracted package
FILE_PKG_NAME=$(ls -1v $DIR_PKG_EXTRACT | grep $FILE_PKG_SEARCH_PATTERN | grep -v 'tar.gz')
if [ ! -d $DIR_PKG_EXTRACT/$FILE_PKG_NAME ] || [ -z $FILE_PKG_NAME ]
then
	Error "Folder not found after extraction"
	Exit $RETVAL_RESTORE_NOTREQUIRED
fi

Msg "Folder: <$DIR_PKG_EXTRACT/$FILE_PKG_NAME>"
VERSION=$(echo $FILE_PKG_NAME | awk -F"_" '{print $3}' | cut -d '.' -f-2)
Msg "New firmware version found = $VERSION"

# Change directory for ease of code writing
cd $DIR_PKG_EXTRACT/

if [ $BACKUP_PKG -eq 0 ]
then
	file_missing=0
	# Check critical file list
	#for f in "${LIST_PKG_CRITICAL_FILES[@]}"
	#do
	#	if [ ! -f $DIR_PKG_EXTRACT/$FILE_PKG_NAME/$f ]
	#	then
	#		Error "Critical file missing: <$FILE_PKG_NAME/$f>"
	#		file_missing=1
	#		break
	#	fi
	#done
	# Exit in case any critical file is missing
	[ $file_missing -eq 1 ] && Exit $RETVAL_RESTORE_NOTREQUIRED

	# MD5SUM Check
	md5sum_mismatch=0; md5sum_notfound=0
	for f in $(find $FILE_PKG_NAME -type f -name "*rpm*" | grep -v "application" | grep -v "md5")
	do
		# Check if file and md5 both are present or not
		if [ ! -f ${f}.md5 ];
		then
			Error "MD5 file not present for file: <$f>"
			md5sum_notfound=1
			break
		fi

		# Verify MD5 sum if present
		md5sum -c ${f}.md5
		if [ $? -ne 0 ]
		then
			Error "MD5sum mismatch for file: <$f>"
			md5sum_mismatch=1
			break
		fi
	done
	# Exit in case MD5 mis-match
	[ $md5sum_notfound -eq 1 ] && Exit $RETVAL_RESTORE_NOTREQUIRED
	[ $md5sum_mismatch -eq 1 ] && Exit $RETVAL_RESTORE_NOTREQUIRED
fi

# Unpack all RPM files
# RPM files are expected to be in drivers/ and swpackages/ directories only
rpm_failure=0
for f in $(find $FILE_PKG_NAME/drivers -type f -name "*.rpm")
do
	# Install the RPM package
	Msg "Installing RPM package: <$f>"
	rpm --reinstall -vh $f
	if [ $? -ne 0 ];
	then
		Error "RPM package installation failed: <$f>"
		rpm_failure=1
		break
	fi
done
[ $rpm_failure -eq 1 ] && Exit $RETVAL_RESTORE_REQUIRED;

ko_failure=0
for f in "${LIST_OLD_FW_DRIVERS[@]}"
do
	if [ -f $FILE_PKG_NAME/drivers/$f ]
	then
		# Install the .ko files
		Msg "Copying driver file: <$f>"
		d=$(dirname $f)
		mkdir -p $DIR_PREFIX/$d #JIJU
		if [ -d $DIR_PREFIX/$d ];
		then
			cp $FILE_PKG_NAME/drivers/$f $DIR_PREFIX/$d
			if [ $? -ne 0 ]
			then
				Error "$f cannot be copied to file system"
				ko_failure=1
				break;
			fi
		else
			Error "$f cannot be copied to file system"
			ko_failure=1
			break
		fi
	else
		Error "Driver .ko file not found: <$f>"
	fi
done
[ $ko_failure -eq 1 ] && Exit $RETVAL_RESTORE_REQUIRED;

rpm_failure=0
for f in $(find $FILE_PKG_NAME/swpackages -type f -name "*.rpm")
do
	# Install the RPM package
	Msg "Installing RPM package: <$f>"
	if [ "$(basename $f)" == "release-files-0.1-r0.cortexa5hf_neon.rpm" ];
	then
		# Remove init-files package as it conflicts with files from release-files
		rpm -e prod-files
		rpm -e init-files
		sync
		sleep 1
	fi
	rpm --reinstall -vh $f
	if [ $? -ne 0 ];
	then
		Error "RPM package installation failed: <$f>"
		rpm_failure=1
		break
	fi
done
[ $rpm_failure -eq 1 ] && Exit $RETVAL_RESTORE_REQUIRED;

cp_failure=0
pushd $DIR_PKG_EXTRACT/$FILE_PKG_NAME/swpackages
LIST_OLD_FW_FILES=$(find * -type f -print)
popd
for f in ${LIST_OLD_FW_FILES[@]}
do
	# Copy the firmware files/folders
	Msg "Copying firmware file: <$f>"
	d=$(dirname $f)
	mkdir -p $DIR_PREFIX/$d
	cp -r $DIR_PKG_EXTRACT/$FILE_PKG_NAME/swpackages/$f $DIR_PREFIX/$d
	if [ $? -ne 0 ]
	then
		Error "$f cannot be copied to file system"
		cp_failure=1
		break;
	fi
done
[ $cp_failure -eq 1 ] && Exit $RETVAL_RESTORE_REQUIRED;

flash_partition=0
# Flash all partitions
for linedata in "${LIST_FLASH_FILES[@]}"
do
	Partition=$(echo $linedata | cut -d "," -f 1)
	File=$(echo $linedata | cut -d "," -f 2)
	retry=0;

	if [ -f $DIR_PKG_EXTRACT/$FILE_PKG_NAME/$File ]
	then
		while [ $retry -lt 3 ];
		do
			let retry++

			flash_eraseall $Partition
			if [ $? -ne 0 ]
			then
				continue
			fi

			nandwrite -p  $Partition $DIR_PKG_EXTRACT/$FILE_PKG_NAME/$File
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
[ $flash_partition -eq 1 ] && Exit $RETVAL_RESTORE_REQUIRED;

sync
Exit $RETVAL_SUCCESS
