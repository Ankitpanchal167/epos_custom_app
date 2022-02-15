#include "SPI.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <iostream>

void spi_dup(unsigned int fd, char *tx_buf,char *rx_buf, int len)
{
    int ret = 0;
    struct spi_ioc_transfer tr = {
        .tx_buf = (unsigned long)tx_buf,
        .rx_buf = (unsigned long)rx_buf,
        .len = len,
        .delay_usecs = delay,
        .speed_hz = speed,
        .bits_per_word = bits,
    };

    ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
    if (ret < 1)
        printf("can't send spi message");

}
unsigned char SPI_sr(unsigned int fd, unsigned char c)
{
	unsigned char tx_buf[20];
	//unsigned char rx_buf[20];

	tx_buf[0] =  c;
	tx_buf[1] =  0x00;
	char buf[2];
	memset(buf,0x00,sizeof(buf));
	//spi_tx(tx_buf, 2);
	spi_dup(unsigned int fd, (char*)tx_buf, buf, 2);

	return buf[1];
}

void spi_rx(unsigned int fd, char *rx_buf , int len)
{
    int ret = 0;

    struct spi_ioc_transfer tr = {
        .tx_buf = (unsigned long)0,
        .rx_buf = (unsigned long)rx_buf,
        .len = len,
        .delay_usecs = delay,
        .speed_hz = speed,
        .bits_per_word = bits,
    };

    ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
    if (ret < 1)
        printf("can't send spi message");

}

