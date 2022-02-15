#!/bin/bash
#
#################################################
#					VERSION						#
#################################################
DIAG_VERSION=1.1

#################################################
#				DIAG DIR PATH					#
#################################################
NOW=$(date '+%d_%m_%Y_%H_%M_%S')
DIAG_DIR=/opt/
DIAG_PKG=epos_peripheral_test
DIAG_PACKAGE_PATH=$DIAG_DIR/$DIAG_PKG
DIAG_SCRIPT_PATH=$DIAG_PACKAGE_PATH/scripts
DIAG_BIN_PATH=$DIAG_PACKAGE_PATH/bin
DIAG_CONFIG_PATH=$DIAG_PACKAGE_PATH/configs
#DIAG_LOG_DIR=/home/root/test_logs
DIAG_LOG_DIR=/tmp/test_logs
DIR_LOG=$DIAG_LOG_DIR/Log
DIR_REPORT=$DIAG_LOG_DIR/Report
FIRMWARE_PKG=/tmp/Images
DIAG_LOG_DIR_REMOTE_PC="~/EPOS_PRODUCTION_TEST_LOGS/"
DIAG_REPORT_FILE=

#################################################
#				VARIABLES   					#
#################################################
PRODUCT_NAME="EPOS"
CONFIGURATION_DONE=0
FIRMWARE_INSTALL_STATUS=0
CLEAR=1
READ_DUMMY_OPTS=0
MANUAL_TEST_NO=0
CONFIG_NO=""
MAIN_MENU_NO=0

declare -a Configurations=(
	"Date_And_Time"
	"Product_Description"
	"Hardware_Version"
	"Serial_Number"
	"Main_Board_PCBA"
	"Power_Board_PCBA"
	"NFC_Board_PCBA"
	"Battery_Serial_No"
	"WiFi_MAC_Address"
	"BSP_Version"
	"Test_Engineer"
)

declare -a ARGS=(
	"NULL"
	"NULL"
	"NULL"
	"NULL"
	"NULL"
	"NULL"
	"NULL"
	"NULL"
	"NULL"
	"NULL"
	"NULL"
)

declare -a TestCases=(
	"Main_LCD"
	"Audio_DAC"
	"Keypad"
	"LEDs"
	"Main_Camera"
	"IRIS_Camera"
	"Finger_print_sensor"
	"Barcode"
	"OLED_display"
	"SD_card"
	"USB_Storage"
	"Tamper"
	"Hardware_Poweroff"
	"Hardware_Poweron"
	"WIFI"
	"Bluetooth"
	"PMIC"
	"Battery_Charger"
	"Battery_Fuel_Gauge"
	"DDR"
	"NAND"
	"Tamper_RTC"
	"Software_Reboot"
	"Software_Poweroff"
	"USB_Cell_modem"
	"NFC"
	"Coin_Cell"
	"Load_Test"
	"Low_Power_Mode"
	"Enable_Battery_Charging"
	"Thermal_Test"
)

TerminateProcess()
{
    process=$1
    # Get the pid of the process
    Ppid=$(pidof $process)
    echo "Terminating process: [$Ppid] <$process>"
    while [ "$Ppid" != "" ];do
        kill -9 $Ppid
        sleep 1
        Ppid=$(pidof $process)
    done
}

TerminateScript()
{
	process=$1
	# Get the pid of the process
	Spid=$(ps -afx | grep -w $process | grep -v grep | awk '{print$1}')
	echo "Terminating script : [$Spid] <$process>"
	while [ "$Spid" != "" ];do
		kill -9 $Spid
		sleep 1
		Spid=$(ps -afx | grep $process | grep -v grep | awk '{print$1}')
	done
}

kill_processes_and_scripts()
{
	SCRIPT_LIST=""
	PROCESS_LIST=""

	# Stop all scripts
	for process in $(echo $SCRIPT_LIST);do
		TerminateScript $process
	done

	# Stop all binaries
	for process in $(echo $PROCESS_LIST);do
	    TerminateProcess $process
	done
}


Add_Header()
{
	echo -ne "
*******************************************************************************
************************** PERIPHERAL TEST REPORT *****************************
*******************************************************************************" > $DIAG_REPORT_FILE

	for i in `seq 0 $(( ${#Configurations[@]} - 1 ))`
	do
		cfg=$(echo ${Configurations[$i]} )
		cfg_val=$(bash $DIAG_SCRIPT_PATH/${Configurations[$i]}.sh --get)
		printf "\n%-21s: %s" "$cfg" "$cfg_val" >> $DIAG_REPORT_FILE
		sync
	done

	echo -ne "
Diagnostics FW       : $DIAG_VERSION
*******************************************************************************

*******************************************************************************
TEST NAME                                         RESULT
*******************************************************************************

" >> $DIAG_REPORT_FILE

	for i in `seq 0 $(( ${#TestCases[@]} - 1 ))`
	do
		tc=$(echo ${TestCases[$i]} )
		printf "%-48s %s\n" "$tc" "NOT_TESTED" >> $DIAG_REPORT_FILE
		sync
	done

	sync
}

Display_Main_Menu()
{
        Display_Menu_Header "MAIN MENU"

        echo -ne "
        1  - Set Configuration
        2  - Auto Test
        3  - Manual Test
        4  - Display Report
        5  - Upload Logs
        6  - Flash Firmware
        e  - Exit

Select: "
}

Display_Set_Configuration()
{
	Display_Menu_Header "CONFIGURATION"
	echo -ne "\nSet Configurations:\n\n"

	for i in `seq 0 $(( ${#Configurations[@]} - 1 ))`
	do
		tc=$(echo ${Configurations[$i]} )
		printf "\t%2d - %-5s\n" "$((i+1))" "$tc"
	done

	echo -ne "
	v - View Configurations
	b - Previous menu

Select: "
}

Display_Manual_Testing()
{
	Display_Menu_Header "MANUAL TEST"

	echo -ne "\nSelect Test Option\n\n"

	for i in `seq 0 $(( ${#TestCases[@]} - 1 ))`
	do
		tc=$(echo ${TestCases[$i]} )
		printf "\t%2d - %-5s\n" "$((i+1))" "$tc"
	done

	echo -ne "\tb  - Previous menu

Select: "

}

Display_Report()
{
	if [ -f $DIAG_REPORT_FILE ] && [ ! -z $DIAG_REPORT_FILE ]; then
		cat $DIAG_REPORT_FILE
	else
		echo -e "\nReport File not Found ..."
	fi
}

Display_Upload_Logs()
{
	[ "$CLEAR" == 1 ] && clear
	Display_Menu_Header "UPLOAD LOGS"
}

Display_Firmware_Install()
{
        Display_Menu_Header "INSTALL FIRMWARE"

        echo -ne "\n
Do you want to install firmware?

Select (Y/n): "
}

View_Configuration()
{
	count=0
	exit_loop=0

	[ "$CLEAR" == 1 ] && clear
	while [ 1 ]
	do
		if [ $exit_loop -eq 1 ];then
			break
		fi

		if [ $count -eq 0 ];then
			count=1
		else
			read garbage
			[ "$CLEAR" == 1 ] && clear
		fi

		Display_Menu_Header "VIEW CONFIGURATIONS"

		for i in `seq 0 $(( ${#Configurations[@]} - 1 ))`
		do
			cfg=$(echo ${Configurations[$i]} )
			cfg_val=$(bash $DIAG_SCRIPT_PATH/${Configurations[$i]}.sh --get)
			printf "%-21s: %s\n" "$cfg" "$cfg_val"
		done

		Display_Temp_Screen "View configurations"
		exit_loop=1

	done
}

Menu_Configuration()
{
	count=0
	exit_loop=0
	read_garbage=1
	break_loop=0

	[ "$CLEAR" == 1 ] && clear
	while [ 1 ]
	do
		if [ $count -eq 0 ];then
			count=1
		else
			[ $read_garbage -eq 1 ] && read garbage
			read_garbage=1
			[ "$CLEAR" == 1 ] && clear
		fi

		Display_Set_Configuration

		#TODO Change OPT logic below. Not working above 9
		if [ $READ_DUMMY_OPTS -eq 1 ];then
			exit_loop=1
			OPT=$(echo $CONFIG_NO | cut -d ',' -f 1)
			CONFIG_NO=$(echo $CONFIG_NO | cut -d ',' -f 2-)
		else
			read OPT
		fi

		[ "$CLEAR" == 1 ] && clear
		case "$OPT" in

			[1-9]|1[0-9])
				#bash $DIAG_SCRIPT_PATH/${Configurations[$((OPT - 1))]}.sh --set | tee -a "$LOG_FILE"
				cfg="${Configurations[$((OPT - 1))]}"
				Display_Menu_Header "$cfg"
				bash $DIAG_SCRIPT_PATH/${cfg}.sh --set "${ARGS[$((OPT - 1))]}"
				ret=$?
				if [ $ret -eq 0 ]
				then
					# Check the data set above
					cfg_val=$(bash $DIAG_SCRIPT_PATH/${cfg}.sh --check)
				else
					cfg_val="NOT_SET"
				fi

				if [ "$cfg_val" == "SET" ];then
					cfg_val=$(bash $DIAG_SCRIPT_PATH/${cfg}.sh --get)
					echo -e "\n$cfg set to $cfg_val"
					echo -e "\nSUCCESS"
				else
					echo -e "\nFAILED"
				fi
				if [ "$READ_DUMMY_OPTS" == "1" ];then
					read_garbage=0
				fi
				;;

			'v') View_Configuration; read_garbage=0 ;;
			'b') exit_loop=1; break ;;
			*) echo -e "\n!!! Wrong Option selected !!!";;
		esac

		# Create report file in case all configurations are done
		CONFIGURATION_DONE=$(check_all_config_set)
		if  [ "$CONFIGURATION_DONE" == "1" ]
		then
			DIAG_REPORT_FILE=$DIR_REPORT/Peripheral_Test_Report_${PRODUCT_NAME}.log
			DIAG_LOG_FILE=$DIR_LOG/Peripheral_Test_Log_${PRODUCT_NAME}_${NOW}.log
			if [ ! -f $DIAG_REPORT_FILE ]; then
				Add_Header
			fi
		fi

		if [ $READ_DUMMY_OPTS -eq 1 ];then
			if [ "$CONFIG_NO" == "" ] || [ "$CONFIG_NO" == "$OPT" ];then
				break;
			fi
		fi

		if [ $exit_loop -eq 0 ];then
			echo -e "\nPress ENTER to continue ..."
		fi
	done
}

Menu_Auto_Test()
{
	[ "$CLEAR" == 1 ] && clear
	Display_Menu_Header "AUTO TEST"
	echo -ne "\n"
	file_missing=0

	declare -a tc_list=()
	for i in $tc_list; do
		echo "$i"
		execute $i "$(echo ${TestCases[$i]})" "\n" >> /dev/null 2>&1 &
	done

	while true
	do
		for i in $tc_list; do
			if [ ! -f "/tmp/file${i}" ];then
				file_missing=1
			fi
		done

		if [ "$file_missing" == "0" ]
		then
			cat $(ls /tmp/file* -v) > /etc/testreport >> /dev/null
			rm /tmp/file*
			sync
			break
		fi
		sleep 1
	done

	Display_Report
	echo -e "Press ENTER to continue ...\n"

	if [ $READ_DUMMY_OPTS -ne 1 ];then
		read garbage
		[ "$CLEAR" == 1 ] && clear
	fi
}

Menu_Manual_Test()
{
	count=0
	exit_loop=0
	read_garbage=1

	[ "$CLEAR" == 1 ] && clear
	while [ 1 ]
	do
		if [ $count -eq 0 ];then
			count=1
		else
			[ $read_garbage -eq 1 ] && read garbage
			read_garbage=1
			[ "$CLEAR" == 1 ] && clear
		fi

		Display_Manual_Testing
		if [ $READ_DUMMY_OPTS -eq 1 ];then
			exit_loop=1
			OPT=$MANUAL_TEST_NO
		else
			read OPT
		fi

		echo -ne "\n"
		case "$OPT" in

			[1-9]|1[0-9]|2[0-9]|3[0-1])
				execute $OPT "${TestCases[$((OPT - 1))]}" "\n"
				;;

			'b')
				exit_loop=1;
				break
				;;
			*)
				echo -e "\n!!! Wrong Option selected !!!"
				;;

		esac

		if [ $READ_DUMMY_OPTS -eq 1 ];then
			break
		fi

		if [ $exit_loop -eq 0 ];then
			echo -e "\nPress ENTER to continue ..."
		fi

	done
}

Menu_Display_Report()
{
    Display_Report
}

Menu_Upload_Logs()
{
	local pass_bit=0

	Display_Upload_Logs
	timer=15
	while [ $timer -ge 0 ]; do
		ip="$(ifconfig | grep -A 1 "wlan0" | grep -A 1 "inet addr" | awk '{print $2}' | cut -d ':' -f 2)"
		if [ "defined$ip" != defined ]; then
			pass_bit=1
			break
		fi
		sleep 1
		let "timer--"
	done

	if [ $pass_bit -ne 1 ]; then
		echo -e "Please connect the WiFi"
		return 1
	fi

	echo "Enter IP Address of host PC"
	read ip_addr
	[ -z $ip_addr ] && { echo -e "\nPlease enter Valid ip address\n"; return 1; }
	validate_ip $ip_addr
	if [ $? -eq 1 ]; then
		echo "Please enter valid IP address"
		return 1
	fi

	ping $ip_addr -c 1
	if [ $? -ne 0 ]; then
		echo "Cannot Ping Host PC. Please check network"
		return 1
	fi

	PCB_ASSEMBLY_NO=MAIN_BOARD_PCBA_NO
	#scp $DIR_LOG/* $hostname1@$ip_addr:~/test_logs/
	mkdir -p $DIAG_LOG_DIR/$PCB_ASSEMBLY_NO/Log
	mkdir -p $DIAG_LOG_DIR/$PCB_ASSEMBLY_NO/Report

	cp $DIR_LOG/* $DIAG_LOG_DIR/$PCB_ASSEMBLY_NO/Log/
	sync
	cp $DIR_REPORT/* $DIAG_LOG_DIR/$PCB_ASSEMBLY_NO/Report/
	sync
	scp -r $DIAG_LOG_DIR/$PCB_ASSEMBLY_NO einfochips@$ip_addr:$DIAG_LOG_DIR_REMOTE_PC
	sync
	rm -rf $DIAG_LOG_DIR/$PCB_ASSEMBLY_NO/
	sync

	return 0
}

Menu_Flash_Firmware()
{
	count=0
	exit_loop=0
	read_garbage=1
	no_firmware=0
	install_status=0

	ret=1
	[ "$CLEAR" == 1 ] && clear
	while [ 1 ]; do
		if [ $count -eq 0 ];then
			count=1
		else
			[ $read_garbage -eq 1 ] && read garbage
			read_garbage=1
			[ "$CLEAR" == 1 ] && clear
		fi

		if [ $no_firmware -eq 1 ];then
			break
		fi

		# 0 - install success
		# 1 - install failure
		if [ $install_status -eq 1 ];then
			break
		fi

		Display_Firmware_Install
		if [ $READ_DUMMY_OPTS -eq 1 ];then
			exit_loop=1
			OPT=$ARGS_FW_UPDATE
		else
			read OPT
		fi

		OPT=$(echo $OPT | tr '[:lower:]' '[:upper:]')

		case "$OPT" in
			'Y')
				[ "$CLEAR" == 1 ] && clear
				echo -e "Installing Firmware\n"
				sleep 4
				bash $DIAG_SCRIPT_PATH/FlashFirmwareNand.sh
				ret=$?
				if [ $ret -eq 1 ]; then
					printf "NAND flash failed\n"
					install_status=1
				else
					printf "NAND flash success\n"
					install_status=0
				fi

				if [ $install_status -eq 0 ];then
					FIRMWARE_INSTALL_STATUS=1
					break;
				fi
				exit_loop=0

				;;
			'N')
				exit_loop=1; break ;;

			*) echo -e "\n!!! Wrong Option selected !!!";;
		esac

		if [ $READ_DUMMY_OPTS -eq 1 ];then
			break
		fi

		if [ $exit_loop -eq 0 ];then
			echo -e "\nPress ENTER to continue ..."
		fi

	done
}

Menu_Main()
{
	count=0
	exit_loop=0
	read_garbage=1

	[ "$CLEAR" == 1 ] && clear
	while [ 1 ]
	do
		if [ $count -eq 0 ];then
			count=1
		else
			[ $read_garbage -eq 1 ] && read garbage
			read_garbage=1
			[ "$CLEAR" == 1 ] && clear
		fi

		Display_Main_Menu
		if [ $READ_DUMMY_OPTS -eq 1 ];then
			exit_loop=1
			OPT=$MAIN_MENU_NO
		else
			read OPT
		fi

		case "$OPT" in

			'1') Menu_Configuration;
				read_garbage=0
				;;

			'2')
				if [ $CONFIGURATION_DONE -eq 1 ]; then
					Menu_Auto_Test; read_garbage=0
				else
					echo -e "\nPress Set Configuration first ..."
				fi
				;;

			'3')
				if [ $CONFIGURATION_DONE -eq 1 ]; then
					Menu_Manual_Test; read_garbage=0
				else
					echo -e "\nPress Set Configuration first ..."
				fi
				;;

			'4') Menu_Display_Report;
				exit_loop=1;
				read_garbage=1
				;;

			'5') Menu_Upload_Logs;
				read_garbage=1
				;;

			'6')
				if [ $CONFIGURATION_DONE -eq 1 ]; then
					Menu_Flash_Firmware;
					exit_loop=1; read_garbage=0
				else
					echo -e "\nPress set Configuration first ..."
				fi
				;;

			'e')
				exit_loop=1;
				remove_init_configuration;
				break
				;;

			*)   echo -e "\n!!! Wrong Option selected !!!"
				;;
		esac

		if [ $READ_DUMMY_OPTS -eq 1 ];then
			break;
		fi

		if [ $exit_loop -eq 0 ];then
			echo -e "\nPress ENTER to continue ..."
		fi

		#if [ $FIRMWARE_INSTALL_STATUS -eq 1 ]; then
		#	break
		#fi

	done
}

execute()
{
	TESTCASE_NUM=$1;shift
	TESTCASE_ID=$1;shift
	STATUS=""

	FILE_NAME="$(echo -e "${TESTCASE_ID}" | sed -e 's/[[:space:]]*$//')"
	LOG_FILE=$DIR_LOG/${FILE_NAME}.log

	echo -e "\nStarting $(echo $TESTCASE_ID | sed -e 's/\s*$//g') test...\n"

	case $TESTCASE_NUM in
		[1-9]|1[0-9]|2[0-9]|3[0-1])
			bash $DIAG_SCRIPT_PATH/"${TestCases[$((TESTCASE_NUM - 1))]}.sh" | tee -a "$LOG_FILE"
			;;
	esac

	ret=${PIPESTATUS[0]}
	if [ $ret == 0 ]; then
		#line='------------------------------------------------'
		line='                                                '
		STATUS="PASS"
	else
		line='------------------------------------------------'
		STATUS="FAIL***"
	fi

	echo -e "\n\nSUMMARY                          "
	echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++"
	printf "%-44s : %s\n" "$TESTCASE_ID" $STATUS
	echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++"
	grep -nr "$TESTCASE_ID" $DIAG_REPORT_FILE > /dev/null
	if [ $? -eq 0 ];then
		sed -i "/$TESTCASE_ID/c\\$(printf "%s %s %s\n" $TESTCASE_ID "${line:${#TESTCASE_ID}}" $STATUS)" $DIAG_REPORT_FILE
	else
		printf "%s %s %s\n" $TESTCASE_ID "${line:${#TESTCASE_ID}}" $STATUS >> $DIAG_REPORT_FILE
	fi

	# Update the test in /etc/testreport
	BitValue=$(cat /etc/testreport)
	if [ "$STATUS" == "PASS" ];then
		echo $BitValue | awk -v n=$TESTCASE_NUM -F "" '{for (i=1;i<=NF;i++) if (i==n) $i="P"}1' OFS="" > /etc/testreport
		echo -n P > /tmp/file$TESTCASE_NUM
	else
		echo $BitValue | awk -v n=$TESTCASE_NUM -F "" '{for (i=1;i<=NF;i++) if (i==n) $i="F"}1' OFS="" > /etc/testreport
		echo -n F > /tmp/file$TESTCASE_NUM
	fi

	sync
}

validate_ip()
{
	local  ip=$1
	local  stat=1

	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		OIFS=$IFS
		IFS='.'
		ip=($ip)
		IFS=$OIFS
		[[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
			&& ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
		stat=$?
	fi
	return $stat
}

remove_init_configuration()
{
	cat /proc/sys/kernel/printk > /tmp/kernel_log_level
	echo 0 0 0 0 > /proc/sys/kernel/printk
}

setup_init_configuration()
{
	# Change back kernel log level as it was before starting diag
	cat /tmp/kernel_log_level > /proc/sys/kernel/printk
	rm /tmp/kernel_log_level
}

check_all_config_set()
{
	cfg=""
	cfg_val="NOT_SET"
	for i in `seq 0 $(( ${#Configurations[@]} - 1 ))`
	do
		cfg=$(echo ${Configurations[$i]} )
		cfg_val=$(bash $DIAG_SCRIPT_PATH/${Configurations[$i]}.sh --check)
		if [ "$cfg_val" == "NOT_SET" ]
		then
			break
		fi
	done

	if [ "$cfg_val" == "SET" ];then
		echo 1
	else
		echo 0
	fi
}

source /opt/epos_peripheral_test/scripts/common.sh

# Create Necessary Directories
mkdir -p $DIAG_LOG_DIR
mkdir -p $DIR_LOG
mkdir -p $DIR_REPORT

[ "$CLEAR" == 1 ] && clear

# Check for arguments from user for running specific test the argument should
# be equal to the test case id from sampling test under main menu
# -a - Auto test
# -m - Manual test
# -t - Time
# -b - Battery serial number
# -M - Main PCBA number
# -P - Power PCBA number
# -N - NFC PCBA number
# -s - Serial number
# -n - Test Engineer name
# -f - Firmware update
#
touch /etc/testreport

if [ $# -ne 0 ];then
	# Process command line...
	while [ $# -gt 0 ]; do
		case $1 in
			-a) shift;
				MAIN_MENU_NO=2;
				export READ_DUMMY_OPTS=1;
				for i in `seq 1 ${#TestCases[@]}`
				do
					echo -n "N" > "/tmp/file$i"
					string="$string""N"
					sync
				done

				echo $string > /etc/testreport

				shift;
				;;

			-m) shift;
				MANUAL_TEST_NO=$1;
				MAIN_MENU_NO=3;
				export READ_DUMMY_OPTS=1;
				shift;
				;;

			-c) shift;
				arg=$1;val=$2
				if [ $arg -le ${#ARGS[@]} ];then
					CONFIG_NO="$CONFIG_NO""$arg,";
					ARGS[$(($arg - 1))]=$val
					MAIN_MENU_NO=1;
					export READ_DUMMY_OPTS=1;
				fi
				;;

			-f) shift;
				ARGS_FW_UPDATE=$1
				MAIN_MENU_NO=6;
				export READ_DUMMY_OPTS=1;
				shift; ;;

			*) shift; ;;
		esac
	done
else
	export READ_DUMMY_OPTS="0"
fi

CONFIGURATION_DONE=$(check_all_config_set)

if  [ "$CONFIGURATION_DONE" == "1" ]
then
	DIAG_REPORT_FILE=$DIR_REPORT/Peripheral_Test_Report_${PRODUCT_NAME}.log
	DIAG_LOG_FILE=$DIR_LOG/Peripheral_Test_Log_${PRODUCT_NAME}_${NOW}.log
	if [ ! -f $DIAG_REPORT_FILE ]; then
		Add_Header
	fi
fi

Menu_Main

