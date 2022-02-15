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
#include "fingerprint.h"
//#include"A365.h"
#include <time.h>

#define  AUTO 1
#define  ACTIVE 2
#define  DETECT 3
#define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))
	int fd;
	int fd_yuv;

unsigned char readreg[32];
unsigned int     ARRAYH, ARRAYW, TOTALPIX;              // actual size
unsigned int     arrayh, arrayw, totalpix;              // working copy
int whitelvl = 10;
int scanN = 1;
unsigned char image[360 * 256];

static void pabort(const char *s)
{
	perror(s);
	abort();
}


static const char *device = "/dev/spidev1.1";
static uint8_t mode;
static uint8_t fp_mode;
static uint8_t bits = 8;
static uint32_t speed = 500000;
static uint16_t delay;

#define XEMPTY_BIT          0x04
#define RRDY_BIT            0x02

#define MAXROW              360 /* Total number of row in sensor pixel matrix */
#define MAXCOLUMN           256 /* Total number of column in sensor pixel matrix */


#define READ_REGS           0x20
#define WRITE_CONTROL_REG 0x4b
#define START_SCAN_CMD 0x01
#define READ_DATA_CMD  0x02



unsigned char tx_buf[20];
unsigned char rx_buf[20];

void spi_dup(char *tx_buf,char *rx_buf,int len)
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
		pabort("can't send spi message");

#if 0
	for (ret = 0; ret < len ; ret++) {
	//	if (!(ret % 6))
	//		puts("");
		printf("%d ", rx_buf[ret]);
	}
	puts("");
#endif


}



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
	for (ret = 0; ret < ARRAY_SIZE(tx); ret++) {
		if (!(ret % 6))
			puts("");
		printf("%.2X ", rx[ret]);
	}
	puts("");
#endif


}

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

#if 0
// send, and receive if wait flag is 1
unsigned char SPI_sr(unsigned char c)
{
		tx_buf[0] =  c;
                tx_buf[1] = 0x00;
                char buf[2];
                memset(buf,0x00,sizeof(buf));
                //      spi_tx(tx_buf, 2);
                spi_dup( tx_buf,buf,1 );
		return buf[0];
}

// check sensor size
unsigned int totalpix;
void FP_chksize(unsigned int *w, unsigned int *h)
{
unsigned char rd;
   // SPI_SSEL(0);
    rd = SPI_sr(0x30);
    rd = SPI_sr(0x31);
    *w = (rd+1)*2;
    rd = SPI_sr(0x00);
    *h = (rd+1)*2;
  //  SPI_SSEL(1);
    sleep(1);
    printf("width:%d height:%d \r\n",*w,*h);

    totalpix=(*w)*(*h);
}


void FP_softreset ()
{
    // soft reset
//    SPI_SSEL(0);
    SPI_sr(0xc1);
//    SPI_SSEL(1);
    usleep(10);
}


// read registers and config data, total 32bytes
void FP_readconfig (unsigned char *s)
{
int i;
unsigned char *sp = s;

  //  SPI_SSEL(0);
    SPI_sr(0x20);

    // read back address 0~31
    for (i = 1; i < 32; i++) {
        *sp++ = SPI_sr(i+0x20);
	printf("reg %d %0x \r\n",i,*(sp-1));
    }
    // read last byte
    *sp++ = SPI_sr(0x00);
  //  SPI_SSEL(1);
}


void FP_readimage (unsigned char *buff)
{
int cnt, n;
unsigned char *ptr, byte;
int totalpix = MAXCOLUMN*MAXROW;
char histogram[128] ;
    ptr = buff;
    for (n = 0; n < 128; n++)
        histogram[n] = 0;

    // scan command
//    SPI_SSEL(0);
    SPI_sr(0x01);
//    SPI_SSEL(1);
    usleep(1000);

    // the first read command
  //  SPI_SSEL(0);
    SPI_sr(0x02);
    cnt = totalpix;
    printf("Image capture start... totalpix: %d ",totalpix);

    while (cnt-- > 0) {
        byte = SPI_sr(0x02);
        if (byte != 255) {
            *ptr++ = byte;
	    printf("data:%d ",byte);
           histogram[byte>>1]+=1;
        }
        else
            cnt++;
    }
   // SPI_SSEL(1);
}
#endif

#if 0
int sensorInit(FPCONFIG *cfg)
{
	    SPI_sr(cfg->Reg0);
    SPI_sr(cfg->Reg1);
    SPI_sr(cfg->Reg2);
    SPI_sr(cfg->Reg3);
    SPI_sr(cfg->Reg4);
    SPI_sr(cfg->Reg5);
    SPI_sr(cfg->Reg6);
    SPI_sr(cfg->Reg7);
    SPI_sr(cfg->Reg8);
    SPI_sr(cfg->Reg9);
    SPI_sr(cfg->RegA);
    SPI_sr(cfg->RegB);
    SPI_sr(cfg->RegC);
    SPI_sr(cfg->RegD);
    SPI_sr(cfg->RegE);
    SPI_sr(cfg->RegF);




	return 0;
}
#endif

void printRegs365()
{

	//unsigned int regData[8];
	unsigned int incr=0;
	//unsigned int val=0;


	/*Get the data*/
	for(incr=0;incr<16;incr++)
	{
        memset(rx_buf,0x00,sizeof(rx_buf));
		tx_buf[0] = READ_REGS + incr ;
		tx_buf[1] = 0x00;
		spi_dup((char *)tx_buf, (char *)rx_buf,2);
	//	spi_tx(tx_buf, 2);
	//	spi_rx(rx_buf,2 );
	//	printf("regdata :%x %x %x %u %u %u %u\r\n",
	//		rx_buf[0],rx_buf[1],rx_buf[2],rx_buf[3],rx_buf[4],rx_buf[5],rx_buf[6]);

		printf("Config Register%d:0x%x \r\n",incr
		,rx_buf[1]);
	}
#if 0
	for(incr=0;incr<8;incr++)
	{
		printf("Reg no: %u, reg Data: %x \n",2*incr+1,( regData[incr] & 0xFF00 ) >> 8);
		printf("Reg no: %u, reg Data: %x \n",2*incr+2, regData[incr] & 0x00FF );
	}
#endif

}



void printRegs()
{

	//unsigned int regData[8];
	//unsigned int incr=0;
	//unsigned int val=0;


	/*Get the data*/
//	for(incr=0;incr<15;incr++)
	{
            memset(rx_buf,0x00,sizeof(rx_buf));
		tx_buf[0] = READ_REGS ;
		tx_buf[1] = 0x00;
		spi_tx((char *)tx_buf, 2);
		spi_rx((char *)rx_buf,15 );
		printf("regdata :%u %u %u %u %u %u %u\r\n",
			rx_buf[0],rx_buf[1],rx_buf[2],rx_buf[3],rx_buf[4],rx_buf[5],rx_buf[6]);
	}
#if 0
	for(incr=0;incr<8;incr++)
	{
		printf("Reg no: %u, reg Data: %x \n",2*incr+1,( regData[incr] & 0xFF00 ) >> 8);
		printf("Reg no: %u, reg Data: %x \n",2*incr+2, regData[incr] & 0x00FF );
	}
#endif

}

void dis_4m_clk()
{
	char tx_buf[4];
	char buf[4];

	tx_buf[0] =  0x49;
	tx_buf[1] =  0x22;
	spi_dup((char *)tx_buf,buf,2);
	usleep(10000);



}

extern unsigned char SPI_sr(unsigned char c);

void hard_reset()
{
	system("echo out > /sys/class/gpio/gpio2/direction");
	usleep(10000);
	system("echo 0 > /sys/class/gpio/gpio2/value");
	usleep(10000);
	system("echo 1 > /sys/class/gpio/gpio2/value");
	usleep(100000);
	system("echo in  > /sys/class/gpio/gpio2/direction");
}


void fp_detect_capture()
{
	int count = 0;
	int cnt1 = 0;
	int cnt = 0;
	char fname[30] ;
	char inte = 1;
//	FP_init(&fpconfig1);
	while (1) { /* some condition here */
		count++;

		uint32_t info = 1; /* unmask */

		int fd = open("/dev/uio0", O_RDWR);
		if (fd < 0) {
		perror("open");
		exit(EXIT_FAILURE);
		}

	       if(inte == 1)
		      {
	//	hard_reset();
		FP_softreset();
		FP_init(&fpconfig1);
		 printRegs365();
		      }
#if 1
		   unsigned int a=0,p=0;
		   for(cnt1 =0 ; cnt1 < 100000 ; cnt1++)
		   {
			   a=SPI_sr(0x03);
			   if (p != a) {
				   p=a;
				   printf("2 status : %d lvl:%d cnt:%d\r\n",a ,SPI_sr(0x33),SPI_sr(0x34));
				   //	 printf( "status1 : %d lvl%x cnt:%x\r\n",SPI_sr(0x03),SPI_sr(39),SPI_sr(40));
				   //	 usleep(1000000);
			   }
		   }
#endif

		ssize_t nb = write(fd, &info, sizeof(info));
		if (nb != (ssize_t)sizeof(info)) {
			perror("write");
			close(fd);
			exit(EXIT_FAILURE);
		}
	//	dis_4m_clk();

		/* Wait for interrupt */
		nb = read(fd, &info, sizeof(info));
		fprintf(stdout, "%u\n", (unsigned)time(NULL));
		printf("Get Interrupt Scanning .... \r\n");
		for(cnt1 =0 ; cnt1 < 2000 ; cnt1++)
		{
		//	 printf( "status : %d lvl%x cnt:%x\r\n",SPI_sr(0x03),SPI_sr(0x33),SPI_sr(0x34));
			if((SPI_sr(0x03) & (0x20)) == (0x20) )
			{
				cnt++;
			//	 printf( "status : %d lvl%x cnt:%x\r\n",SPI_sr(0x03),SPI_sr(0x33),SPI_sr(0x34));
				//	 printf( "status1 : %d lvl%x cnt:%x\r\n",SPI_sr(0x03),SPI_sr(39),SPI_sr(40));
				usleep(100000);
			}
			if(cnt > 7)
			{
				break;
			}

		}
		printf("CNT %d lvl:%x\r\n",cnt,SPI_sr(0x33));
		if(cnt > 7 )
		{
		printf("Finger Deteted...  \r\n");
		printf("Capturing Image...  \r\n");
		inte = 1;
		for(cnt1 =0 ; cnt1 < 1000 ; cnt1++)
		cnt = 0;
		}
		else
		{
			cnt = 0;
			inte = 0;
			continue;
		}

#if 1
	//	hard_reset();
		FP_softreset();
		FP_init(&fpconfig0);
	//	FP_chksize(&ARRAYW, &ARRAYH);
		memset(image,0x00,sizeof(image));
	//	FP_auto(image,110,0);
		FP_readimage(image);
		memset(fname,0x00,sizeof(fname));
		sprintf(fname , "fp_%d.yuv",count);
		printf("FP Image Capture in file : %s \r\n",fname);
		fd_yuv = open(fname, O_CREAT | O_RDWR);
		if(fd_yuv)
		{
			write(fd_yuv,image,MAXROW*MAXCOLUMN);
			close(fd_yuv);
//			sleep(1);

		}
		break;

#endif
	}

	exit(EXIT_SUCCESS);

}




void readImage365( unsigned char *image_ptr )
{
	//unsigned int cntr_x = 0;
	unsigned int cntr_y = 0;
	//unsigned int val    = 0;


#if 0
	do
	{
		memset(tx_buf,0x00,sizeof(tx_buf));
		memset(rx_buf,0x00,sizeof(rx_buf));
		tx_buf[0] =  READ_SPI_STATUS;
		tx_buf[1] = 0x00;
		spi_tx(tx_buf, 2);
		spi_rx(rx_buf,1 );

	//	val = rx_buf[0] | (rx_buf[1] << 8) ;
		printf("val %d %d\r\n",rx_buf[0],rx_buf[1]);


//		spi_tx( READ_SPI_STATUS, 0x00 );
//		val = spi_rx( );
	}while( !( val & 0x0100 ) );
#endif

//	spi_tx(READ_SPI_DATA, 0x00 );
//	val = spi_rx( );
//	spi_tx(READ_SPI_DATA, 0x00 );
//	val = spi_rx( );
//	spi_tx(READ_SPI_DATA, 0x00 );
//	val = spi_rx( );

#if 0
//Note : we got first 50 Invalid pixel so need to avoid this we implemt following step(Reson unknown)
        	tx_buf[0] =  READ_SPI_DATA;
		tx_buf[1] = 0x00;
		char buf[MAXCOLUMN];
		memset(buf,0x00,sizeof(buf));
		//	spi_tx(tx_buf, 2);
		//	spi_rx(image_ptr[cntr_y],MAXCOLUMN );
		spi_dup( tx_buf,buf,50 );
#endif



	for( cntr_y = 0; cntr_y < MAXROW*MAXCOLUMN; )
	{

                  //Read Image Data
		tx_buf[0] =  READ_DATA_CMD;
		tx_buf[1] = 0x00;
		char buf[MAXCOLUMN];
		memset(buf,0x00,sizeof(buf));
		//	spi_tx(tx_buf, 2);
		//	spi_rx(image_ptr[cntr_y],MAXCOLUMN );
		spi_dup((char *)tx_buf,buf,2 );
		memcpy( (image_ptr + cntr_y ),buf,2);

		//	val = rx_buf[0]  ;

		//	printf("%d",val);
		if(cntr_y % MAXCOLUMN != 0)
		{
			//		printf("\r\n");
		}

//Debug Data
#if 0
		//	spi_tx(READ_SPI_DATA, 0x00 );
		//	val = spi_rx( );

		//		val = ( ~val );
		//		 *image_ptr  = val;
		//	*image_ptr = ( ( val & 0xFF00 ) >> 8 );
		//		image_ptr++;
		//	*image_ptr = ( val & 0x00FF );
		//	image_ptr++;

#endif
		cntr_y++;
	}


}




void readImage( unsigned char *image_ptr )
{
	//unsigned int cntr_x = 0;
	unsigned int cntr_y = 0;
	//unsigned int val    = 0;


#if 0
	do
	{
		memset(tx_buf,0x00,sizeof(tx_buf));
		memset(rx_buf,0x00,sizeof(rx_buf));
		tx_buf[0] =  READ_SPI_STATUS;
		tx_buf[1] = 0x00;
		spi_tx(tx_buf, 2);
		spi_rx(rx_buf,1 );

	//	val = rx_buf[0] | (rx_buf[1] << 8) ;
		printf("val %d %d\r\n",rx_buf[0],rx_buf[1]);


//		spi_tx( READ_SPI_STATUS, 0x00 );
//		val = spi_rx( );
	}while( !( val & 0x0100 ) );
#endif

//	spi_tx(READ_SPI_DATA, 0x00 );
//	val = spi_rx( );
//	spi_tx(READ_SPI_DATA, 0x00 );
//	val = spi_rx( );
//	spi_tx(READ_SPI_DATA, 0x00 );
//	val = spi_rx( );

#if 0
//Note : we got first 50 Invalid pixel so need to avoid this we implemt following step(Reson unknown)
        	tx_buf[0] =  READ_SPI_DATA;
		tx_buf[1] = 0x00;
		char buf[MAXCOLUMN];
		memset(buf,0x00,sizeof(buf));
		//	spi_tx(tx_buf, 2);
		//	spi_rx(image_ptr[cntr_y],MAXCOLUMN );
		spi_dup( tx_buf,buf,50 );
#endif



	for( cntr_y = 0; cntr_y < MAXROW; )
	{

                  //Read Image Data
		tx_buf[0] =  READ_DATA_CMD;
		tx_buf[1] = 0x00;
		char buf[MAXCOLUMN];
		memset(buf,0x00,sizeof(buf));
		//	spi_tx(tx_buf, 2);
		//	spi_rx(image_ptr[cntr_y],MAXCOLUMN );
		spi_dup((char *) tx_buf,buf,MAXCOLUMN );
		memcpy( (image_ptr + cntr_y*MAXCOLUMN ),buf,MAXCOLUMN);

		//	val = rx_buf[0]  ;

		//	printf("%d",val);
		if(cntr_y % MAXCOLUMN != 0)
		{
			//		printf("\r\n");
		}

//Debug Data
#if 0
		//	spi_tx(READ_SPI_DATA, 0x00 );
		//	val = spi_rx( );

		//		val = ( ~val );
		//		 *image_ptr  = val;
		//	*image_ptr = ( ( val & 0xFF00 ) >> 8 );
		//		image_ptr++;
		//	*image_ptr = ( val & 0x00FF );
		//	image_ptr++;

#endif
		cntr_y++;
	}


}




#if 0
static void transfer(int fd)
{
	int ret;
	uint8_t tx[] = {
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0x40, 0x00, 0x00, 0x00, 0x00, 0x95,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
		0xDE, 0xAD, 0xBE, 0xEF, 0xBA, 0xAD,
		0xF0, 0x0D,
	};
	uint8_t rx[ARRAY_SIZE(tx)] = {0, };
	struct spi_ioc_transfer tr = {
		.tx_buf = (unsigned long)tx,
		.rx_buf = (unsigned long)rx,
		.len = ARRAY_SIZE(tx),
		.delay_usecs = delay,
		.speed_hz = speed,
		.bits_per_word = bits,
	};

	ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
	if (ret < 1)
		pabort("can't send spi message");

	for (ret = 0; ret < ARRAY_SIZE(tx); ret++) {
		if (!(ret % 6))
			puts("");
		printf("%.2X ", rx[ret]);
	}
	puts("");
}
#endif

static void print_usage(const char *prog)
{
	printf("Usage: %s [-DsbdlHOLC3]\n", prog);
	puts("  -D --device   device to use (default /dev/spidev1.1)\n"
	     "  -s --speed    max speed (Hz)\n"
	     "  -d --delay    delay (usec)\n"
	     "  -b --bpw      bits per word \n"
	     "  -l --loop     loopback\n"
	     "  -H --cpha     clock phase\n"
	     "  -O --cpol     clock polarity\n"
	     "  -L --lsb      least significant bit first\n"
	     "  -C --cs-high  chip select active high\n"
	     "  -3 --3wire    SI/SO signals shared\n");
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
			{ "AUTO",   0, 0, 'A' },
			{ "ACTIVE",   0, 0, 'V' },
			{ "DETECT",   0, 0, 'T' },
			{ NULL, 0, 0, 0 },
		};
		int c;

		c = getopt_long(argc, argv, "D:s:d:b:lHOLC3NRAVT", lopts, NULL);

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
		case 'A':
			fp_mode = AUTO;
		         break;
		case 'V':
			fp_mode = ACTIVE;
		         break;
		case 'T':
			fp_mode = DETECT;
		         break;




		default:
			print_usage(argv[0]);
			break;
		}
	}
}

int main(int argc, char *argv[])
{
	printf("##### %d %s \r\n",argc , argv[1]);
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

/***************************************************************/
	//Rest FP
	FP_softreset();
	//Init A365 Fp sensor
	 FP_initscan();

	 if(fp_mode == DETECT)
	 {
	       fp_detect_capture();
	//	 FP_init(&fpconfig1);
		 int cnt1 = 0;
		 unsigned int a=0,p=0;
		 for(cnt1 =0 ; cnt1 < 100000 ; cnt1++)
		 {
			 a=SPI_sr(0x03);
			 if (p != a) {
				 p=a;
				 printf("1 status : %d lvl%x cnt:%x\r\n",a ,SPI_sr(0x33),SPI_sr(0x34));
				 usleep(1000);
			 }

		 }

	 }
	 else
	 {
	 FP_init(&fpconfig0);
	 }
//	sensorInit(&fpconfig0);
	//Read back config regidter
	FP_readconfig(readreg);
	//Check Semsor size
	FP_chksize(&ARRAYW, &ARRAYH);
	printRegs365();
//	printRegs();
	memset(image,0x00,sizeof(image));
//	readImage(image);
//	Capture FP Image in 8bpp format
	if(fp_mode == AUTO)
	{
	printf("#### IN Auto Mode ###### \r\n");
	FP_auto(image,110,0);
	}
	else if(fp_mode == ACTIVE)
	{
	 printf("###### IN ACTIVE Mode ###### \r\n");
	 FP_readimageA(image, scanN, whitelvl);
	 FP_histogram();
	}
	else
	{
	printf("#### IN Normal Mode ###### \r\n");
	FP_readimage(image);
	}
/***************************************************************/


int i = 0;
//int j = 0;
	printf("############################ \r\n");
#if 1
for(i =0 ; i< MAXROW*MAXCOLUMN ; i++)
{
//	printf("%x ",image[i]);



#if 0
	printf("****** \r\n");
	for(j = 0 ; j <  MAXCOLUMN ; j++)
	{
	printf("%x ",image[i][j]);
	}
	printf("****** \r\n");

#endif
}

fd_yuv = open("test.yuv", O_CREAT | O_RDWR);
if(fd_yuv)
{
	write(fd_yuv,image,MAXROW*MAXCOLUMN);
	close(fd_yuv);

}



#if 1


#endif

#endif
printf("############################ \r\n");


	close(fd);

	return ret;
}
