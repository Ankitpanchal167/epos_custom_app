/*----------------------------------------------------------------------------
 * fingerprint.c: fingerprint sensor driver
 * Written by FCL
 * Copyright SunASIC, Inc. 2017
 * Note(s):1
*----------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "fingerprint.h"
#include "A365.h"
#include <time.h>
#include <unistd.h>
#include <string.h>
#include <sys/time.h>
#include "SPI.h"

unsigned int     ARRAYH, ARRAYW, TOTALPIX;              // actual size
unsigned int     arrayh, arrayw, totalpix;              // working copy
unsigned int     histogram[128];                        // statistic
//int              fp_mean, fp_variance;
//int              fp_hi, fp_lo, fp_med, fp_cover;
FPSTAT           fpstat;
unsigned int     fp_lvl, fp_cnt;
FPCONFIG         *config;
#define PKT_SIZE  128

#define USCNT 22
static void delay (int n)
{
	usleep(n*1000);
}


void FP_init (FPCONFIG *cfg)
{
	char tx_buf[18];
	char buf[18];
	tx_buf[0] =  0x40;
	tx_buf[1] =  cfg->Reg0;
	tx_buf[2] =  cfg->Reg1;
	tx_buf[3] =  cfg->Reg2;
	tx_buf[4] =  cfg->Reg3;
	tx_buf[5] =  cfg->Reg4;
	tx_buf[6] =  cfg->Reg5;
	tx_buf[7] =  cfg->Reg6;
	tx_buf[8] =  cfg->Reg7;
	tx_buf[9] =  cfg->Reg8;
	tx_buf[10] = cfg->Reg9;
	tx_buf[11] =  cfg->RegA;
	tx_buf[12] =  cfg->RegB;
	tx_buf[13] =  cfg->RegC;
	tx_buf[14] =  cfg->RegD;
	tx_buf[15] =  cfg->RegE;
	tx_buf[16] =  cfg->RegF;
	memset(buf,0x00,sizeof(buf));
	spi_dup( tx_buf,buf,17);
	delay(2);
	FP_initotp ();
	delay(100);

	tx_buf[0] =  0x49;
	tx_buf[1] =  0x22;
	spi_dup( tx_buf,buf,2);
	delay(100);
}

#if 0
// load registers
void FP_init (FPCONFIG *cfg)
{
    config = cfg;
//    SPI_SSEL(0);
    SPI_sr(0x40); // Write regs command
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
  //  SPI_SSEL(1);

    delay(2);
    FP_initotp ();
    delay(10);
}
#endif

// read registers and config data, total 32bytes
void FP_readconfig (unsigned char *s)
{
int i;
unsigned char *sp = s;

//    SPI_SSEL(0);
    SPI_sr(0x20);

    // read back address 0~31
    for (i = 1; i < 32; i++) {
        *sp++ = SPI_sr(i+0x20);
    }
    // read last byte
    *sp++ = SPI_sr(0x00);
 //   SPI_SSEL(1);
}

// read status flags
int FP_status()
{
int st;
  //  SPI_SSEL(0);
    SPI_sr(0x03);
    st = SPI_sr(0x00);
  //  SPI_SSEL(1);
    return st;
}

// fingerprint interrupt
int FP_intr()
{
    return ((FP_status()&0x20)!=0);
}

// check finger detect status
void FP_detst()
{
   // SPI_SSEL(0);
    SPI_sr(0x33);
    fp_lvl = SPI_sr(0x34);
    fp_cnt = SPI_sr(0x00);
  //  SPI_SSEL(1);
    delay(5);
}

void FP_initotp ()
{
   // SPI_SSEL(0);
    SPI_sr(0x4);
  //  SPI_SSEL(1);
    delay(20);
};

#if 1
//TODO
void FP_hardreset ()
{
   // SPI_SSEL(0);
    SPI_sr(0x4a);   // force T1 as input
    SPI_sr(0x00);
    SPI_sr(0x00);
    SPI_sr(0x00);
  //  SPI_SSEL(1);
    delay(1);
   // SPI_T1DIR(1);   // set IO port as output
    SPI_RST(0);     // toggle reset
    delay(1);
    SPI_RST(1);
    delay(5);

    // fix a leakage problem
  //  SPI_SSEL(0);
    SPI_sr(0x4F);
    SPI_sr(config->RegF);
  //  SPI_SSEL(1);
    delay(5);
}
#endif
void FP_softreset ()
{
    SPI_sr(0x4c);
    SPI_sr(0x16);
    // soft reset
   // SPI_SSEL(0);
    SPI_sr(0xc1);
  //  SPI_SSEL(1);
    delay(10);
}

void FP_setoffs(int val)
{
    config->Reg5 = setbit(config->Reg5, 0, 127, val);
  //  SPI_SSEL(0);
    SPI_sr(0x45); // Write regs command
    SPI_sr(config->Reg5);
  //  SPI_SSEL(1);
    delay(1);
}

// read OTP content, total 32bytes
void FP_readotp (unsigned char *s)
{
int i;

    // initialize OTP
   // SPI_SSEL(0);
    SPI_sr(0x04);
   // SPI_SSEL(1);
    delay(10);

    for (i = 0; i < 32; i++) {
        // set otp address
     //   SPI_SSEL(0);
        SPI_sr(0x4d);  // start with otpadr
        SPI_sr(i);
       // SPI_SSEL(1);

        delay(5);
       // SPI_SSEL(0);
        SPI_sr(0x4f);  // skip one reg
        SPI_sr(0x02);  // OTP AE
       // SPI_SSEL(1);
        delay(5);

       // SPI_SSEL(0);
        SPI_sr(0x4f);
        SPI_sr(0x03);  // OTP AE + OE
       // SPI_SSEL(1);
        delay(5);

       // SPI_SSEL(0);
        SPI_sr(0x07);  // OTP read data
        *s++ = SPI_sr(0x00);
       // SPI_SSEL(1);
        delay(5);

        // clear otp command
       // SPI_SSEL(0);
        SPI_sr(0x4f);
        SPI_sr(0x00);
       // SPI_SSEL(1);
        delay(5);
    }
}

// check sensor size
unsigned int totalpix;
void FP_chksize(unsigned int *w, unsigned int *h)
{
	//unsigned char rd;
//    SPI_SSEL(0);
    *w = SPI_sr(0x30);
    *h = SPI_sr(0x31);

//    printf("11 width :%d height:%d \r\n",*w , *h);

//    *w = SPI_sr(0x24);
 //   *h = SPI_sr(0x25);
  //  printf("11 width :%d height:%d \r\n",*w , *h);


    *w = (*w+1)*2;
    *h = (*h+1)*2;
  //  SPI_SSEL(1);
 //   delay(5);
    printf("width :%d height:%d ",*w , *h);

    totalpix=(*w)*(*h);
}




// read image
unsigned int    histogram[128];
#if 1
void FP_readimage (unsigned char *buff)
{
	//int cnt;
   	int n;
	unsigned  int i = 0;
//unsigned char *ptr;
//unsigned char byte;
    //ptr = buff;

    for (n = 0; n < 128; n++)
        histogram[n] = 0;
//printf("11 \r\n");

    // scan command
//    SPI_SSEL(0);
    SPI_sr(0x01);
   // SPI_sr(0x01);
   // SPI_sr(0x01);
//    SPI_SSEL(1);
    usleep(100000);   //To Be chceck need to reduce
//printf("22 \r\n");

    // the first read command
  //  SPI_SSEL(0);
    //cnt = totalpix;
  totalpix =  360 * 256;
    printf("Image capture start... totalpix: %d \r\n",totalpix);
//printf("33 \r\n");

    /*TODO Check total capture time better to get data in bulk insted of byte by byte*/

    struct timeval stop, start;
    gettimeofday(&start, NULL);
//BYTE read very slow take 700 milli second
#if 0
    for(i = 0;i < totalpix;i++) {
        buff[i] = SPI_sr(0x02);
    //  printf(" image[%d] : %u \r\n",i,buff[i] );
	  histogram[ (unsigned char)buff[i]>>1]+=1;
    }
 #endif

    //Bulk read Faser than BYTE read take 200 milli second time
#if 1
    for(i = 0 ; i < totalpix/PKT_SIZE ; i++)
    {

	     char tx_buf[PKT_SIZE + 1] ;
             char rx_buf[PKT_SIZE + 1] ;
	     int j = 0 ;

             memset(rx_buf,0x00,sizeof(rx_buf));
             memset(tx_buf,0x02,sizeof(tx_buf));
               // tx_buf[0] = 0x02 ;
               // tx_buf[1] = 0x02;
               // tx_buf[2] = 0x02;
               // tx_buf[3] = 0x02;
               // tx_buf[4] = 0x02;
                spi_dup(tx_buf,rx_buf,PKT_SIZE +1);
                memcpy(buff + ( i * PKT_SIZE  ),rx_buf + 1,PKT_SIZE);
		//Histrogram
		for(j = 1 ; j < PKT_SIZE +1 ; j++)
		{
			 histogram[ (unsigned char)rx_buf[j]>>1]+=1;
		}
               // i++;

    }
#endif
    gettimeofday(&stop, NULL);
    printf("took %lu us\n", (stop.tv_sec - start.tv_sec) * 1000000 + stop.tv_usec - start.tv_usec);
    printf("Image Captured.... \r\n");
   // SPI_SSEL(1);
}

#endif


#if 0
void FP_readimage (unsigned char *buff)
{
int cnt, n;
unsigned char *ptr, byte;

    ptr = buff;
    for (n = 0; n < 128; n++)
        histogram[n] = 0;

    // scan command
  //  SPI_SSEL(0);
    SPI_sr(0x01);
  //  SPI_SSEL(1);
    delay(1);

    // the first read command
  //  SPI_SSEL(0);
    SPI_sr(0x02);
    cnt = totalpix;

    while (cnt-- > 0) {
        byte = SPI_sr(0x02);
        if (byte != 255) {
            *ptr++ = byte;
            histogram[byte>>1]+=1;
        }
        else
            cnt++;
    }
  //  SPI_SSEL(1);
}
#endif

// integer square root
static int sqrti (int x)
{
int i, v, v0;

    i=0;
    for(v=x; v; v=v>>1)
        i++;
    v=x>>(i>>1); //estimated initial value by half shift
    v0=0;
    for(;v && v!=v0; ) {
        v0=v;
        v=v+(x-(v*v))/(2*v);
    }
    return v;
}

// high/low tail percentage of pixels
#define TAILSZ (totalpix/10)
#define WRANGE 15
// image statistic
void FP_histogram (void)
{
	int     i, j, n;
	int     hi=0, lo=0, sum;
	long long mean, var;

	printf("line :%d \r\n",__LINE__);
    // mean
    mean = n = 0;
    for (i=0; i < 128; i++) {
        n += histogram[i];
	printf("his : %d ",histogram[i]);
        mean += histogram[i]*i;
    }
	printf("line :%d %d \r\n",__LINE__,n);
    fp_mean = (mean<<8) / n;

	printf("line :%d \r\n",__LINE__);
    // variance
    var = 0;
    for (i=0; i < 128; i++)
        var += histogram[i]*(((fp_mean-(i<<8))*(fp_mean-(i<<8))+128)>>8);
    var = var/n;
    fp_variance = sqrti(var<<10);
    fp_mean = 2 * fp_mean;

	printf("line :%d \r\n",__LINE__);
    // tail end, dark side
    sum = 0;
    for (i = 0; i < 128; i++) {
        if (TAILSZ >= (sum+histogram[i])) {
            sum += histogram[i];
        } else {
            lo = i;
            break;
        }
    }

	printf("line :%d \r\n",__LINE__);
    // light side
    sum = 0;
    for (i = 127; i >= 0; i--) {
        if (TAILSZ >= (sum+histogram[i])) {
            sum += histogram[i];
        } else {
            hi = i;
            break;
        }
    }
    fp_med = lo+hi;
    fp_hi = hi*2;
    fp_lo = lo*2;

	printf("line :%d \r\n",__LINE__);
    sum = 0;
    j = 0;
    for (i = 127; i >= 0; i--) {
        if (histogram[i] == 0) {
                continue;
        }
        if (j == 0)
            j = i;
        sum += histogram[i];
        if (i == j-WRANGE)
            break;
    }
	printf("line :%d \r\n",__LINE__);
    fp_cover = 256-256*sum/n;
}

void FP_initscan()
{
    config=&fpconfig0;
    //FP_init(config);
}

void FP_initdetect()
{
    config=&fpconfig1;
    //FP_init(config);
}

// auto offset/gain adjust
static int gval[] = {4, 5, 6, 7, 8, 10, 12, 14};
// two global variable are set: fp_mean and
// return value - target white level
int FP_auto(unsigned char *buff, int target, int autogain)
{
	printf("line :%d ",__LINE__);
int offs, gain0;
int tar, doffs, span, gain;
//Need to check
char *fpimage = malloc(360 * 256);

    FP_initscan();
	printf("line :%d ",__LINE__);
    offs=get_offs();
    gain0=get_gain();
    set_gain(0);
    FP_fastmode(1);

	printf("line :%d ",__LINE__);
again:
    FP_init(&fpconfig0);
	printf("line :%d ",__LINE__);
    FP_readimage((unsigned char *)fpimage);
	printf("line :%d ",__LINE__);
    FP_histogram();
	printf("line :%d ",__LINE__);

	printf("line :%d ",__LINE__);
    if (fp_mean < 10*256) {
        offs+=8;
        offs=(offs>127)? 127: offs;
        set_offs(offs);
        goto again;
    }

    if (fp_mean > 244*256) {
        offs-=8;
        offs=(offs < 0)? 0: offs;
        set_offs(offs);
        goto again;
    }

	printf("line :%d ",__LINE__);
    span=fp_hi-fp_lo;
    // find gain
    if (autogain) {
        if (span < D1)
            gain=((int)(4.*GMAX))*(span-D0)/(D1-D0);
        else
            gain=((int)(4.*GMAX));
        gain=(gain>2*4)? gain/2 : gain-4;
        gain=(gain>7)? 7 : (gain<0)? 0 : gain;
        set_gain(gain);
        gain0=gain;
    } else
        set_gain(gain0);

    // find new offset
    //target=TAEGET0-fp_variance*(WHITE-CENTR)/(V1-V0);
    if (target != -1)
        tar = target<<8;
    else {
        tar=TAEGET0-span*256*(WHITE-CENTR)/(V1-V0);
        tar=(tar>(WHITE<<8))? (WHITE<<8): (tar<(CENTR*256))? CENTR*256: tar;
    }
    //doffs=(target-fp_mean)/SLOPE;     // use mean
    //doffs=(tar-(fp_med<<8))/SLOPE;
    doffs=((128<<8)-(fp_med<<8)+(tar-(128<<8))*gval[0]/gval[gain0])/SLOPE;   // use median
    offs=get_offs()+doffs;
     offs=get_offs()+doffs;
    offs=(offs>127)?127:(offs<0)?0:offs;
    set_offs(offs);

    // done
    FP_fastmode(0);
    return (tar>>8);

}
void FP_fastmode(int fast)
{
    if (fast) {
        fpconfig0.RegB |= 0x80;
        arrayw = ARRAYW/4;
        arrayh = ARRAYH/4;
        totalpix = TOTALPIX/16;
    } else {
        fpconfig0.RegB &= 0x7f;
        arrayw = ARRAYW;
        arrayh = ARRAYH;
        totalpix = TOTALPIX;
    }
}

void FP_getstat(FPSTAT *ptr)
{
    *ptr = fpstat;
}

