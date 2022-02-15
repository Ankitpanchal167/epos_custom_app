@@ReadMe file 

This test program is written to test the communication channel and basic functionalities of the PN7462 configured for Raspberry Pi 4 
SPI2 Channel is used 
Chip Select GPIO 18
IRQ         GPIO 25

The program tests the following sequences 
1. Initialise the SPI interface 
2. Read the device configuration
3. start the contactless polling 
4. Poll for status of PN7642
5. On card detection
6. Read the UID of the card 
7. Read ATR of the card 
8. Deactivate the card 