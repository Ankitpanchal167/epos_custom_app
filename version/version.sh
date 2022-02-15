#!/bin/bash

bsp_version=0
serial_no=0
main_pcb_no=0
power_pcb_no=0
nfc_pcb_no=0
battery_serial_no=0

FILE_SERIAL_NUMBER=/etc/serial.txt
FILE_BATTERY_SERIAL_NUMBER=/etc/battery_serial.txt
FILE_MAIN_BOARD_PCBA_NUMBER=/etc/main_pcb_no.txt
FILE_POWER_BOARD_PCBA_NUMBER=/etc/power_pcb_no.txt
FILE_NFC_BOARD_PCBA_NUMBER=/etc/nfc_pcb_no.txt
FILE_BSP_VERSION=/etc/bsp_version.txt

# To get version number of releases shared by EIC
if [ -f $FILE_SERIAL_NUMBER ];then
    serial_no=`cat $FILE_SERIAL_NUMBER`
fi
[ -z $serial_no ] && serial_no=0

# To get version number of releases shared by EIC
if [ -f $FILE_BATTERY_SERIAL_NUMBER ];then
    battery_serial_no=`cat $FILE_BATTERY_SERIAL_NUMBER`
fi
[ -z $battery_serial_no ] && battery_serial_no=0

# To get version number of releases shared by EIC
if [ -f $FILE_MAIN_BOARD_PCBA_NUMBER ];then
    main_pcb_no=`cat $FILE_MAIN_BOARD_PCBA_NUMBER`
fi
[ -z $main_pcb_no ] && main_pcb_no=0

# To get version number of releases shared by EIC
if [ -f $FILE_POWER_BOARD_PCBA_NUMBER ];then
    power_pcb_no=`cat $FILE_POWER_BOARD_PCBA_NUMBER`
fi
[ -z $power_pcb_no ] && power_pcb_no=0

# To get version number of releases shared by EIC
if [ -f $FILE_NFC_BOARD_PCBA_NUMBER ];then
    nfc_pcb_no=`cat $FILE_NFC_BOARD_PCBA_NUMBER`
fi
[ -z $nfc_pcb_no ] && nfc_pcb_no=0

# To get version number of releases shared by EIC
if [ -f $FILE_BSP_VERSION ];then
    bsp_version=`cat $FILE_BSP_VERSION`
fi
[ -z $bsp_version ] && bsp_version=0

# WiFi MAC address
wifi_mac=$(ifconfig | grep 'HWaddr' | cut -d ' ' -f 10)
if [ "$wifi_mac" == "" ];then
	wifi_mac="00:00:00:00:00:00"
fi

echo "BSP package version: $bsp_version"
echo "Board Serial       : $serial_no"
echo "Main board PCBA    : $main_pcb_no"
echo "Power board PCBA   : $power_pcb_no"
echo "NFC board PCBA     : $nfc_pcb_no"
echo "Battery serial     : $battery_serial_no"
echo "WIFI MAC           : $wifi_mac"
