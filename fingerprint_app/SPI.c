#include "SPI.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <iostream>

// SPI RESET high/low
void SPI_RST(unsigned char val)
{
    if (val) { // set
        system("echo 1 > /sys/class/gpio2/value");
    }
    else { // clear
        system("echo 0 > /sys/class/gpio2/value");

    }
}


unsigned char SPI_sr(unsigned char c)
{
	unsigned char tx_buf[20];
	//unsigned char rx_buf[20];

	tx_buf[0] =  c;
	tx_buf[1] =  0x00;
	char buf[2];
	memset(buf,0x00,sizeof(buf));
	//      spi_tx(tx_buf, 2);
	spi_dup((char*)tx_buf,buf,2);

	return buf[1];
}


#if 0
// send, and receive if wait flag is 1
unsigned char SPI_sr(unsigned char c)
{
	unsigned char tx_buf[20];
	unsigned char rx_buf[20];

                tx_buf[0] =  c;
                tx_buf[1] = 0x00;
                char buf[2];
                memset(buf,0x00,sizeof(buf));
                //      spi_tx(tx_buf, 2);
                spi_dup( tx_buf,buf,1 );
                return buf[0];
}

#endif
