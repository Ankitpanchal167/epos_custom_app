#!/bin/bash

source /opt/epos_peripheral_test/scripts/common.sh

i2c_bus=2
i2c_addr="0x18"

detect_audio_dac()
{
	i2cdetect -r -y $i2c_bus > /dev/null
	ret=$?
	if [ "$ret" != "0" ]; then
		printlog "I2C Bus $i2c_bus is not initialized properly\n"
		print_result 1
	fi

	ret=" "
	ret=$(i2cdetect -r -y $i2c_bus | head -n 3 | tail -n 1 | awk '{print $10}')
	if [ "0x$ret" == "$i2c_addr" ] || [ "$ret" == "UU" ]
	then
		print_status "Audio DAC Detect" "PASS"
	else
		print_status "Audio DAC Detect" "FAIL"
		print_result 1
	fi
}

initialize_dac()
{
	amixer -c 0 cset iface=MIXER,name="HP Driver Playback Switch" 1
	amixer -c 0 cset iface=MIXER,name="DAC Left Input" 1
	amixer -c 0 cset iface=MIXER,name="DAC Right Input" 1
	amixer -c 0 cset iface=MIXER,name="HP Analog Playback Volume" 60
	amixer -c 0 cset iface=MIXER,name="HP Driver Playback Volume" 3
	amixer -c 0 cset iface=MIXER,name="HP Left Switch" 1
	amixer -c 0 cset iface=MIXER,name="HP Right Switch" 1
	amixer -c 0 cset iface=MIXER,name="Output Left From Left DAC" 1
	amixer -c 0 cset iface=MIXER,name="Output Right From Right DAC"  1
	amixer -c 0 cset iface=MIXER,name="DAC Playback Volume" 127
	amixer -c 0 cset iface=MIXER,name="Speaker Switch"  1
	amixer -c 0 cset iface=MIXER,name="Speaker Left Switch" 1
	amixer -c 0 cset iface=MIXER,name="Speaker Driver Playback Switch" 1
	amixer -c 0 cset iface=MIXER,name="DAC Playback Volume"  140
	amixer -c 0 cset iface=MIXER,name="Speaker Analog Playback Volume"  74
	amixer -c 0 cset iface=MIXER,name="Speaker Driver Playback Volume" 3
}

play_sample_audio()
{
	printlog "Playing Sample Audio 5 Times\n"
	sleep 1
	for i in {1..5}
	do
		aplay /usr/share/sounds/alsa/Front_Center.wav 2> /dev/null
	done

	printlog "Is Audio playing?? Press(y/N):"
	read ANS

	[ -z $ANS ] && ANS="N"

	if [ $ANS == "Y" ] || [ $ANS == "y" ]; then
		print_status "Audio Play" "PASS"
	else
		print_status "Audio Play" "FAIL"
		print_result 1
	fi
}

# Step 1:- Detect Audio DAC on I2C
detect_audio_dac

# Step 2:- Initialize Audio dac
if [ "$READ_DUMMY_OPTS" == "1" ];then
	initialize_dac
fi

#Step 3:- Play Sample Audio
play_sample_audio
print_result 0

