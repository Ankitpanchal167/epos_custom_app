# Power modes
# ------------------------------------------------

# PMIC - Predone on driver load

# Keypad - Predone on driver load

# WIFI - Disable WLAN_EN
ifconfig wlan0 down

# BT - Disable BT_EN
echo 104 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio104/direction
echo 0 > /sys/class/gpio/gpio104/value

# OV7725 - Predone on driver load

# OV7740 - Predone on driver load

# With current design, disabling AVDD LDO increases system power consumption
# upto 10mA at 5V ext power supply.

# AVDD LDO - Disable
#LED=160
#echo $LED > /sys/class/gpio/export
#echo out > /sys/class/gpio/gpio$LED/direction
#echo 0 > /sys/class/gpio/gpio$LED/value

# Audio - Predone on driver load

# Barcode - Reset nTRIG
LED=161
echo $LED > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$LED/direction
echo 1 > /sys/class/gpio/gpio$LED/value

# FP - Reset
LED=2
echo $LED > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$LED/direction
echo 0 > /sys/class/gpio/gpio$LED/value

# LEDs - Disable
LED=16 #red
echo $LED > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$LED/direction
echo 0 > /sys/class/gpio/gpio$LED/value

LED=21 #yellow
echo $LED > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$LED/direction
echo 0 > /sys/class/gpio/gpio$LED/value

LED=28 #green
echo $LED > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$LED/direction
echo 0 > /sys/class/gpio/gpio$LED/value

LED=29 #orange
echo $LED > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$LED/direction
echo 0 > /sys/class/gpio/gpio$LED/value

LED=62 #FP led
echo $LED > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$LED/direction
echo 0 > /sys/class/gpio/gpio$LED/value

# OLED - Reset
LED=1
echo $LED > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio$LED/direction
echo 0 > /sys/class/gpio/gpio$LED/value

# IR led - Turn off
echo 4 > /sys/class/backlight/backlight/bl_power

# LCD - Turn off backlight
echo 1 > /sys/class/graphics/fb0/blank

# NFC - Unknown

# SDCard

# Nand

# DDR

# Processor
echo mem > /sys/power/state
