/*----------------------------------------------------------------------------
 * fingerprintA.c: fingerprint sensor driver, white point based
 * Written by FCL
 * Copyright SunASIC, Inc. 2018
 * Note(s):
*----------------------------------------------------------------------------*/

#include "spiport.h"
#include "fingerprint.h"

static void abit(int r)
{
    config->RegA = setbit(config->RegA, 3, 1, r);
    SPI_SSEL(0);
    SPI_sr(0x4A); // Write regs command
    SPI_sr(config->RegA);
    SPI_SSEL(1);
    delay(1);
}

static void FP_setoffs(int val)
{
    config->Reg5 = setbit(config->Reg5, 0, 127, val);
    SPI_SSEL(0);
    SPI_sr(0x45); // Write regs command
    SPI_sr(config->Reg5);
    SPI_SSEL(1);
    delay(1);
}

static void readadd (unsigned char *buff, int offs, int mean, int sign)
{
int i, d;
unsigned char *ptr, byte;

    ptr = buff;
    FP_setoffs(offs);

    // scan command
    SPI_SSEL(0);
    SPI_sr(0x01);
    SPI_SSEL(1);
    delay(1);

    // the first read command
    SPI_SSEL(0);
    SPI_sr(0x02);
    i = totalpix;
    if (sign==0)
        while (i-- > 0) {
            byte = SPI_sr(0x02);
            if (byte != 255) {
                d=*ptr+byte-mean;
                d = (d>255)? 255: d;
                d = (d<0)? 0: d;
                *ptr++=d;
            }
            else
                i++;
        }
    else
        while (i-- > 0) {
            byte = SPI_sr(0x02);
            if (byte != 255) {
                d=*ptr-byte+mean;
                d = (d>255)? 255: d;
                d = (d<0)? 0: d;
                *ptr++=d;
            }
            else
                i++;
        }
    SPI_SSEL(1);
}

static void FP_inithist (void)
{
unsigned int n;
    for (n = 0; n < 128; n++)
        histogram[n] = 0;
}

static void FP_readimageN (unsigned char *buff, int i)
{
unsigned char *ptr, byte;

    SPI_SSEL(0);
    SPI_sr(0x01);
    SPI_SSEL(1);
    ptr = buff;
    FP_inithist();
    delay(20);
    SPI_SSEL(0);
    SPI_sr(0x02);

    while (i-- > 0) {
        byte = SPI_sr(0x02);
        if (byte != 255) {
            *ptr++ = byte;
            histogram[byte>>1]+=1;
        }
        else
            i++;
    }
    SPI_SSEL(1);
}

#define TAIL10TH (TOTALPIX/(16*10))
unsigned int stdspan[] = {90, 72, 60, 51, 45, 36, 30, 25};
unsigned int slope[] = { 1766,2208,2650,3091,3533,4416,5299,6182};

#define SPANADJ 512
#define MINSPAN 25
#define HP 200
#define LP (256-HP)

int FP_autoWhite (unsigned char *fpbuff, int whitelvl)
{
int i, hi, lo, sum, offs, span, gain, dv;
unsigned char *ptr;
static int offs0 = -1;
static int mean0 = 128;

    // Note that offs0 can be stored in Flash and restored on power-up
    // the value -1 forces calibration each time
    config=&fpconfig0;
    if (offs0 < 0) {
        int n, h2;
        // find cross over point
        offs0 = offs = ((ARRAYW==176)?18:60);
        config->Reg6=4;         // gain = 4 (double)
        config->RegB |= 0x80;   // fast mode
        config->RegA |= 0x08;   // signal polarity
again:
        //printf("\r\n\r\n*** again: offs=%d\r\n",offs);
        if (offs < 0 || offs > 127) {
            offs0 = -1;
            return -1;
        }
        config->Reg5 = offs;
        FP_init(config);
        FP_readimageN(fpbuff, TOTALPIX/16);

        // check high side average
        for (n = sum = 0, i = 127; i >= 0; i--) {
            n += histogram[i];
            sum += i*histogram[i];
            if (n >= TAIL10TH) {
                if (i > 192/2) { // slope = 14, 14*4=56
                    offs -= 4;
                    goto again;
                } else if (i < 64/2) {
                    offs += 4;
                    goto again;
                }
                sum = sum - (n-TAIL10TH)*i - 127*histogram[127];
                n = TAIL10TH - histogram[127];
                h2 = 512*sum/n;
                //printf("\r\n\r\n*(gain=4, offs=%d) h2 = 256*%d\r\n", offs, sum*2/n);
                break;
            }
        } 
        // gain=0
        config->Reg6=0;
        FP_init(config);
        FP_readimageN(fpbuff, TOTALPIX/16);     

        // check high side average
        for (n = sum = 0, i = 127; i >= 0; i--) {
            n += histogram[i];
            sum += i*histogram[i];
            if (n >= TAIL10TH) {
                sum = sum - (n-TAIL10TH)*i - 127*histogram[127];
                n = TAIL10TH - histogram[127];
                hi = 512*sum/n;
                //printf("*(gain=0, offs=%d) h2 = 256*%d\r\n", offs, sum*2/n);
                if (hi > h2)
                    offs0 = offs + (hi-h2+128*7)/(256*7);
                else
                    offs0 = offs - (h2-hi+128*7)/(256*7);
                break;
            }
        }
        
        config->Reg5 = offs0;
        FP_init(config);
        FP_readimageN(fpbuff, TOTALPIX/16);
        
        // get average background value at offs0
        for (n = sum = 0, i = 127; i >= 0; i--) {
            n += histogram[i];
            sum += i*histogram[i];
            if (n >= TAIL10TH) {
                sum = sum - (n-TAIL10TH)*i - 127*histogram[127];
                n = TAIL10TH - histogram[127];
                hi = 512*sum/n;
                mean0=sum*2/n;
                //printf("*mean0=%d\r\n", sum*2/n);
                break;
            }
        }
        //printf("(offs0=%d, mean0=%d)\r\n", offs0, mean0);
    }

    FP_softreset ();
    config->Reg6=0;         // gain = 0
    config->RegB |= 0x80;   // fast mode
    config->RegA |= 0x08;   // signal polarity
    config->Reg5 = offs0+(HP-mean0)*256/slope[0];
    FP_init(config);
    FP_readimageN(fpbuff, TOTALPIX/16);

    // check span and set gain
    for (sum = 0, i = 0; i < 128; i++) {
        sum += histogram[i];
        if (sum > TAIL10TH) {
            lo = (i==0)?0:i-1;
            break;
        }
    }
    // light side
    for (sum = 0, i = 127; i >= 0; i--) {
        sum += histogram[i];
        if (sum > TAIL10TH) {
            hi = (i==127)?127:i+1;
            break;
        }
    }
    span = (hi-lo)*SPANADJ/256; // larger SPANADJ reduces gain

    gain=0;
    if (span > MINSPAN) {
        for (i = 0; i<7 ; i++)
            if (span > stdspan[i])
                break;
        gain=i;
    }
    
    //printf("offs0=%d, hi=%d, lo=%d, span=%d, gain=%d\r\n", offs0, hi*2, lo*2, span, gain);
    FP_softreset ();
    if (whitelvl > 0)
        dv=whitelvl-HP+LP;
    else
        dv=span*slope[gain]/(slope[0]*2)+128-HP+LP;
    config->Reg6 = setbit(config->Reg6, 0, 7, gain);
    offs=offs0+(HP*256-mean0*256)/slope[gain];
    config->Reg5=offs;
    config->RegB&=0x7f; // fast mode off
    abit(1);
    FP_init(config);
    FP_readimageN(fpbuff,TOTALPIX);
    abit(0);
    offs=offs0-(mean0*256-LP*256)/slope[gain];
    readadd(fpbuff,offs,dv,1);
    abit(1);

    // histogram
    for (i = 0; i < 128; i++)
        histogram[i] = 0;
    ptr = fpbuff;
    i = TOTALPIX;
    while (i-- > 0) {
        histogram[*ptr++/2]+=1;
    }
    return 0;
}

