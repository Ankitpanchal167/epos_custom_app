/*----------------------------------------------------------------------------
 * fingerprintA.c: fingerprint sensor driver
 * Written by FCL
 * Copyright SunASIC, Inc. 2017
 * Note(s):
*----------------------------------------------------------------------------*/

//#include "spiport.h"
#include "fingerprint.h"
#include <string.h>
#include <unistd.h>
#include "SPI.h"

static void delay (int n)
{
        usleep(n*1000);
}

static void abit(int r)
{
    config->RegA = setbit(config->RegA, 3, 1, r);
//    SPI_SSEL(0);
    SPI_sr(0x4A); // Write regs command
    SPI_sr(config->RegA);
  //  SPI_SSEL(1);
    delay(1);
}

static void reada (unsigned char *buff, int offs, int mean, int sign)
{
int cnt, d;
unsigned char *ptr, byte;

    ptr = buff;
    FP_setoffs(offs);

    // scan command
   // SPI_SSEL(0);
    SPI_sr(0x01);
   // SPI_SSEL(1);
    delay(1);

    // the first read command
   // SPI_SSEL(0);
//    SPI_sr(0x02);
    cnt = totalpix;
    if (sign==0)
        while (cnt-- > 0) {
            byte = SPI_sr(0x02);
            if (byte != 255) {
                d=*ptr+byte-mean;
                d = (d>255)? 255: d;
                d = (d<0)? 0: d;
                *ptr++=d;
            }
            else
                cnt++;
        }
    else
        while (cnt-- > 0) {
            byte = SPI_sr(0x02);
            if (byte != 255) {
                d=*ptr-byte+mean;
                d = (d>255)? 255: d;
                d = (d<0)? 0: d;
                *ptr++=d;
            }
            else
                cnt++;
        }
   // SPI_SSEL(1);
}

#define ADJ 20

void FP_readimageA (unsigned char *buff, int nn, int target)
{
int i, cnt;
unsigned char *ptr;
int offs0, offs1, mean0, mean1;

    FP_initscan();

    abit(0);
    FP_auto(buff, 128+ADJ, 0);
    offs1=get_offs();
    mean1=fp_mean>>8;

    abit(1);
    FP_auto(buff, 128-ADJ, 0);
    offs0=get_offs();
    mean0=fp_mean>>8;

    FP_init(config);
    FP_readimage(buff);

    abit(0);
    nn=(nn<0)? 0: (nn>16)? 16: nn;
    reada(buff, offs1, ((target>0)? target:mean1)+2*ADJ,1);
    for (i = 0; i < nn; i++) {
        abit(1);
        reada(buff, offs0, mean0, 0);
        abit(0);
        reada(buff, offs1, mean1, 1);
    }
    abit(1);

    // histogram
    for (cnt = 0; cnt < 128; cnt++)
        histogram[cnt] = 0;
    ptr = buff;
    cnt = totalpix;
    while (cnt-- > 0) {
        histogram[*ptr++/2]+=1;
    }
   // SPI_SSEL(1);

    delay(10);
}
