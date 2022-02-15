/*----------------------------------------------------------------------------
 * fingerprintA.c: fingerprint sensor driver
 * Written by FCL
 * Copyright SunASIC, Inc. 2017
 * Note(s):
*----------------------------------------------------------------------------*/

#include <string.h>
//#include "spiport.h"
#include "fingerprint.h"
#include "SPI.h"
#include <unistd.h>

static void delay (int n)
{
        usleep(n*1000);
}

/*
unsigned char *cbuf;            // reference frame
unsigned char *fpimage;         // image buffer
int i, tar, refmean;

// capturing reference image
    FP_auto(cbuf,128,0);
    FP_init(config);
    FP_readimage(cbuf);
    FP_histogram();
    refmean=fp_mean>>8;

// capture normal image

    if (auto_offs)
        tar=FP_auto(fpimage,-1,0);
    FP_init(config);
    FP_readimageC (cbuf, refmean, fpimage, tar, 0);
*/

// reference image, reference mean, image buffer, target brightness, enhancement count
void FP_readimageC (unsigned char *refimg, unsigned int rmean, unsigned char *buff, int target, int nn)
{
int cnt, d, r, n, i;
unsigned char *ptr, byte;

    for (n = 0; n < 128; n++)
        histogram[n] = 0;

    // find proper offset
    FP_auto(buff, 128, 0);
    FP_init(config);
    ptr = buff;
    memcpy(buff, refimg, totalpix);
    r = target-128+rmean;

    // scan command
//    SPI_SSEL(0);
    SPI_sr(0x01);
  //  SPI_SSEL(1);
    delay(10);

    // the first read command
  //  SPI_SSEL(0);
//    SPI_sr(0x02);
    cnt = totalpix;
    while (cnt-- > 0) {
        byte = SPI_sr(0x02);
        if (byte != 255) {
            d=byte-*ptr+r;
            d = (d>255)? 255: d;
            d = (d<0)? 0: d;
            //histogram[d>>1]+=1;
            *ptr++=d;
        }
        else
            cnt++;
    }
   // SPI_SSEL(1);

    while (nn-- > 0) {
        unsigned char *r, *p;
        r = refimg;
        p = buff;

        // scan command
     //   SPI_SSEL(0);
        SPI_sr(0x01);
      //  SPI_SSEL(1);
        delay(10);

        // the first read command
      //  SPI_SSEL(0);
  //      SPI_sr(0x02);
        cnt = totalpix;

        while(cnt-- > 0) {
            byte = SPI_sr(0x02);
            if (byte != 255) {
                d=byte+*p-*r++;
                d = (d>255)? 255: d;
                d = (d<0)? 0: d;
                *p++=d;
            } else
                cnt++;
        }
       // SPI_SSEL(1);
    }

    ptr=buff;
    for (i=0; i<totalpix; i++)
        histogram[(*ptr++)>>1]+=1;
}
