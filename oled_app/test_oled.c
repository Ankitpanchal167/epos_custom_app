/*
 * SPI testing utility (using spidev driver)
 *
 * Copyright (c) 2007  MontaVista Software, Inc.
 * Copyright (c) 2007  Anton Vorontsov <avorontsov@ru.mvista.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License.
 *
 * Cross-compile with cross-gcc -I/path/to/cross-kernel/include
 */

#include <stdint.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <string.h>

#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))
	int fd;
	int fd_yuv;


char str[10]= "1234.56";
#define GPIO_DC
static void pabort(const char *s)
{
	perror(s);
	abort();
}

static const char *device = "/dev/spidev2.0";
static uint8_t mode;
static uint8_t bits = 8;
static uint32_t speed = 100000;
static uint16_t delay = 0;
static int display_off = 0;
unsigned char tx_buf[576];
//unsigned char rx_buf[576];
unsigned char buff[36][16] = {
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
};

unsigned char d_0[36][2] ={
0x3F,0xFC,
0x3F,0xFC,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x3F,0xFC,
0x3F,0xFC
};
unsigned char d_1[36][2] ={
0x3F,0xFC,
0x3F,0xFC,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0x80,
0x01,0xF0,
0x01,0xF0,
0x01,0x80,
0x01,0x80
};
unsigned char d_2[36][2] ={
0x3F,0xFC,
0x3F,0xFC,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x3F,0xFC,
0x3F,0xFC,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x3F,0xFC,
0x3F,0xFC
};
unsigned char d_3[36][2] ={
0x3F,0xFC,
0x3F,0xFC,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x3F,0xFC,
0x3F,0xFC,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x3F,0xFC,
0x3F,0xFC
};
unsigned char d_4[36][2] ={
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x3F,0xFC,
0x3F,0xFC,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C
};
unsigned char d_5[36][2] ={
0x3F,0xFC,
0x3F,0xFC,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x3F,0xFC,
0x3F,0xFC,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x3F,0xFC,
0x3F,0xFC
};
unsigned char d_6[36][2] ={
0x3F,0xFC,
0x3F,0xFC,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x3F,0xFC,
0x3F,0xFC,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x00,0x0C,
0x3F,0xFC,
0x3F,0xFC
};
unsigned char d_7[36][2] ={
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x3F,0xFC,
0x3F,0xFC
};
unsigned char d_8[36][2] ={
0x3F,0xFC,
0x3F,0xFC,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x3F,0xFC,
0x3F,0xFC,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x3F,0xFC,
0x3F,0xFC
};
unsigned char d_9[36][2] ={
0x3F,0xFC,
0x3F,0xFC,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x30,0x00,
0x3F,0xFC,
0x3F,0xFC,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x30,0x0C,
0x3F,0xFC,
0x3F,0xFC
};

unsigned char d_dot[36][2] ={
0x03,0xC0,
0x03,0xC0,
0x03,0xC0,
0x03,0xC0,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00,
0x00,0x00
};

void spi_tx(char *tx_buf,int len)
{
	int ret = 0;
	struct spi_ioc_transfer tr = {
		.tx_buf = (unsigned long)tx_buf,
		.rx_buf = (unsigned long)0,
		.len = len,
		.delay_usecs = delay,
		.speed_hz = speed,
		.bits_per_word = bits,
	};

	ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
	if (ret < 1)
		pabort("can't send spi message");

#if 0
	for (ret = 0; ret < len; ret++) {
		if (!(ret % 16))
			puts("");
		printf("%.2X ", tx_buf[ret]);
	}
	puts("");
#endif


}

/*
void spi_rx(char *rx_buf , int len)
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
		pabort("can't send spi message");

#if 0
	for (ret = 0; ret < len; ret++) {
		if (!(ret % 6))
//			puts("");
	//	printf("%.2X ", rx_buf[ret]);
	}
//	puts("");
#endif


}
*/

static void print_usage(const char *prog)
{
	printf("Usage: %s [-DsbdlHOLC3S]\n", prog);
	puts("  -D --device   device to use (default /dev/spidev1.1)\n"
	     "  -s --speed    max speed (Hz)\n"
	     "  -d --delay    delay (usec)\n"
	     "  -b --bpw      bits per word \n"
	     "  -l --loop     loopback\n"
	     "  -H --cpha     clock phase\n"
	     "  -O --cpol     clock polarity\n"
	     "  -L --lsb      least significant bit first\n"
	     "  -C --cs-high  chip select active high\n"
	     "  -3 --3wire    SI/SO signals shared\n"
	     "  -S --data     digit\n"
	     "  -x --off      switch off display\n");

	exit(1);
}

static void parse_opts(int argc, char *argv[])
{
	while (1) {
		static const struct option lopts[] = {
			{ "device",  1, 0, 'D' },
			{ "speed",   1, 0, 's' },
			{ "delay",   1, 0, 'd' },
			{ "bpw",     1, 0, 'b' },
			{ "loop",    0, 0, 'l' },
			{ "cpha",    0, 0, 'H' },
			{ "cpol",    0, 0, 'O' },
			{ "lsb",     0, 0, 'L' },
			{ "cs-high", 0, 0, 'C' },
			{ "3wire",   0, 0, '3' },
			{ "no-cs",   0, 0, 'N' },
			{ "ready",   0, 0, 'R' },
			{ "data",    1, 0, 'S' },
			{ "off",     0, 0, 'x' },
			{ NULL, 0, 0, 0 },
		};
		int c;

		c = getopt_long(argc, argv, "D:s:d:S:b:lHOLC3NRx", lopts, NULL);

		if (c == -1)
			break;

		switch (c) {
		case 'D':
			device = optarg;
			break;
		case 's':
			speed = atoi(optarg);
			break;
		case 'd':
			delay = atoi(optarg);
			break;
		case 'S':
			snprintf( str, 10, "%s", optarg );
			break;
		case 'b':
			bits = atoi(optarg);
			break;
		case 'l':
			mode |= SPI_LOOP;
			break;
		case 'H':
			mode |= SPI_CPHA;
			break;
		case 'O':
			mode |= SPI_CPOL;
			break;
		case 'L':
			mode |= SPI_LSB_FIRST;
			break;
		case 'C':
			mode |= SPI_CS_HIGH;
			break;
		case '3':
			mode |= SPI_3WIRE;
			break;
		case 'N':
			mode |= SPI_NO_CS;
			break;
		case 'R':
			mode |= SPI_READY;
			break;
		case 'x':
			display_off = 1;
			break;
		default:
			print_usage(argv[0]);
			break;
		}
	}
}

int main(int argc, char *argv[])
{
	int ret = 0;

	parse_opts(argc, argv);

	fd = open(device, O_RDWR);
	if (fd < 0)
		pabort("can't open device");

	/*
	 * spi mode
	 */
	ret = ioctl(fd, SPI_IOC_WR_MODE, &mode);
	if (ret == -1)
		pabort("can't set spi mode");

	ret = ioctl(fd, SPI_IOC_RD_MODE, &mode);
	if (ret == -1)
		pabort("can't get spi mode");

	/*
	 * bits per word
	 */
	ret = ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &bits);
	if (ret == -1)
		pabort("can't set bits per word");

	ret = ioctl(fd, SPI_IOC_RD_BITS_PER_WORD, &bits);
	if (ret == -1)
		pabort("can't get bits per word");

	/*
	 * max speed hz
	 */
	ret = ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed);
	if (ret == -1)
		pabort("can't set max speed hz");

	ret = ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed);
	if (ret == -1)
		pabort("can't get max speed hz");

	printf("spi mode: %d\n", mode);
	printf("bits per word: %d\n", bits);
	printf("max speed: %d Hz (%d KHz)\n", speed, speed/1000);

	// Reset
	//system("echo 1 > /sys/class/gpio/export");
	//system("echo out > /sys/class/gpio/gpio1/direction");
	//system("echo 0 > /sys/class/gpio/gpio1/value");
	//usleep(10000);
	//system("echo 1 > /sys/class/gpio/gpio1/value");
	//system("echo 49 > /sys/class/gpio/export");
	//system("echo out > /sys/class/gpio/gpio49/direction");
	//system("echo 1 > /sys/class/gpio/gpio49/value");
	//printf("Reset done\n");
	//usleep(10000);

	//Release Standby Mode;
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x14;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x00;
	spi_tx((char *)tx_buf, 1);

	//Set Display OFF;
	if (display_off == 1) {
		system("echo 0 > /sys/class/gpio/gpio49/value");
		tx_buf[0] = 0x02;
		spi_tx((char *)tx_buf, 1);

		system("echo 1 > /sys/class/gpio/gpio49/value");
		tx_buf[0] = 0x00;
		spi_tx((char *)tx_buf, 1);

		// Reset
		system("echo 1 > /sys/class/gpio/export");
		system("echo out > /sys/class/gpio/gpio1/direction");
		system("echo 0 > /sys/class/gpio/gpio1/value");
		return 0;
	}

	//Set Frame Frequency
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x1A;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x05;
	spi_tx((char *)tx_buf, 1);

	//Set Data Writing Direction
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x1D;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x0B;
	spi_tx((char *)tx_buf, 1);

	//Set Scan Direction
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x09;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x00;
	spi_tx((char *)tx_buf, 1);

	//Set Column Driver Active Range;
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x30;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x00;
	tx_buf[1] = 0x7F;
	spi_tx((char *)tx_buf, 2);

	//Set ROW Driver Active Range;
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x32;
	spi_tx((char *)tx_buf, 1);

	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x04;
	tx_buf[1] = 0x27;
	spi_tx((char *)tx_buf, 2);

	//Set Column Start Line;
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x34;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x00;
	spi_tx((char *)tx_buf, 1);

	//Set Column End Line
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x35;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x0F;
	spi_tx((char *)tx_buf, 1);

	//Set Row Start Line
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x36;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x04;
	spi_tx((char *)tx_buf, 1);

	//Set Row End Line
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x37;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x27;
	spi_tx((char *)tx_buf, 1);

	//Set Peak Pulse Width
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x10;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x1F;
	spi_tx((char *)tx_buf, 1);

	//Set Peak Pulse Delay Width
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x16;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x05;
	spi_tx((char *)tx_buf, 1);

	//Set Pre-charge Width
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x18;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x1F;
	spi_tx((char *)tx_buf, 1);

	//Set ROW Scan Sequence
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x13;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x01;
	spi_tx((char *)tx_buf, 1);

	//Set Contrast Control
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x12;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x3F;
	spi_tx((char *)tx_buf, 1);

	//Set VDD Selection
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x3D;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x00;
	spi_tx((char *)tx_buf, 1);

	//Set Display ON
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x02;
	spi_tx((char *)tx_buf, 1);

	system("echo 1 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x01;
	spi_tx((char *)tx_buf, 1);

	printf("############################ \r\n");

	int i = 0,col=14,dig;
	int len = strlen(str);
	unsigned char ptr[36][2];

	i = 0;
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x08;
	spi_tx((char *)tx_buf, 1);
	memcpy(tx_buf,buff,sizeof(buff));

	//system("echo 1 > /sys/class/gpio/gpio49/value");
	//spi_tx((char *)tx_buf, 576);

	col-=(16-(len*2));
	for(dig=0; dig<len; dig++)
	{
		switch(str[dig])
		{
			case '0':
				memcpy(ptr,d_0,sizeof(d_0));
				break;
			case '1':
				memcpy(ptr,d_1,sizeof(d_1));
				break;
			case '2':
				memcpy(ptr,d_2,sizeof(d_2));
				break;
			case '3':
				memcpy(ptr,d_3,sizeof(d_3));
				break;
			case '4':
				memcpy(ptr,d_4,sizeof(d_4));
				break;
			case '5':
				memcpy(ptr,d_5,sizeof(d_5));
				break;
			case '6':
				memcpy(ptr,d_6,sizeof(d_6));
				break;
			case '7':
				memcpy(ptr,d_7,sizeof(d_7));
				break;
			case '8':
				memcpy(ptr,d_8,sizeof(d_8));
				break;
			case '9':
				memcpy(ptr,d_9,sizeof(d_9));
				break;
			case '.':
				memcpy(ptr,d_dot,sizeof(d_dot));
				break;
		}

		for(i=0;i<36;i++)
		{
			memcpy(buff[i]+col,ptr[i],sizeof(ptr[i]));
		}
		col-=2;
	}

	i = 0;
	system("echo 0 > /sys/class/gpio/gpio49/value");
	tx_buf[0] = 0x08;
	spi_tx((char *)tx_buf, 1);
	memcpy(tx_buf,buff,sizeof(buff));

	system("echo 1 > /sys/class/gpio/gpio49/value");
	spi_tx((char *)tx_buf, 576);

	//sleep (1);

	close(fd);

	return ret;
}
