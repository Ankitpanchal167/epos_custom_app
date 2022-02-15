/*----------------------------------------------------------------------------
 * Name:    Demo.c
 * Purpose: Finger print demo main program
 * Written by Frederick Lin
 * Copyright SunASIC, Inc. 2014
 * Note(s):
 *----------------------------------------------------------------------------*/

#include <RTL.h>
#include <rl_usb.h>
#include <stm32f4xx.h>                  /* STM32F4xx Definitions              */
#include <stdio.h>
#include <stdlib.h>
// #include "I2C.h"
#include "LED.h"
// #include "ADC.h"
// #include "TSC.h"
#include "usart.h"
#include "GLCD.h"
#include "SPI.h"
//#include "debug.h"
#include "fingerprint.h"
#include "fingerprintC.h"
#define __FPCFG_H
#include "mychip.h"
#include "keys.h"
#include "timer.h"
#include "menu.h"
#include "memory.h"
//#include "detect.h"
//#include "config.h"

#define DBG(x) GLCD_DisplayString (0, 30, 1, x);

/*----------------------------------------------------------------------------
  update file name
 *----------------------------------------------------------------------------*/

unsigned char Memory[MSC_HeaderSize];
unsigned char *IRAM1 = (unsigned char *)0x20000000;

unsigned char *fpimage;     // image buffer
unsigned char readreg[32];
int           useroffs = 180;
unsigned char ascii[] = "0123456789ABCDEF";
int           autogain=0;

#define DEMO_COLOR 0 // 0x23cf

// operation modes
//                           123456789A
unsigned char modecode[] = "-PACNROEXFG-";
#define PASSIV 1
#define ACTIVE 2
#define CALIB_FF 3
#define CHECK 4
#define SHOWREG 5
#define SHOWOTP 6
#define DETECT 7
#define ENCRYPT 8
#define M5 9
#define M5C 10
#define LASTMODE 10
#define DEFAULTMODE 1

void pause() 
{
    while(key==0);
    key=0;
}

int main (void) {
int i, n;
// unsigned char test[16] ,testrcv[16];
// uint16_t DeviceCode;
int bar, cnt, gain, offs, refmean, whitelvl;
//unsigned char *p;
int offsx, offsy;
int dir=1;
int auto_offs=1;
unsigned char lcdmsg[64];
unsigned char *cbuf, *p;

    SysTick_Config(SystemCoreClock/100000);   // Generate interrupt each 10us
//    usbd_init();                      // USB Initialization
//    usbd_connect(__FALSE);

    //extclock();
    LED_Init();                       // LED Init
    KEY_Init();                       // Keyboard Init
    USART_Configuration();
    //DBG_init();
    GLCD_Init();                      // Graphical Display Init
    GLCD_Clear(DEMO_COLOR);

    // reset SPI and make sure hw reset can be used
    SPI_init();
    //SPI_setclock(0);
tryagain:
    FP_hardreset();
    FP_readconfig(readreg);
    FP_chksize(&ARRAYW, &ARRAYH);
    TOTALPIX = ARRAYH*ARRAYW;
    if (ARRAYH == 512 || ARRAYW == 512) {
    // if (ARRAYH > 360 || ARRAYH < 112 || ARRAYW > 256 || ARRAYW < 80) {
        GLCD_DisplayString (0, 0, 1, "Unable to identify chip");
        sprintf(lcdmsg, "Size: %d %d", ARRAYW, ARRAYH);
        GLCD_DisplayString (1, 0, 1, lcdmsg);
        // show_state(0);
        timer_delay(1, 100, 1);
        //if (ARRAYW != 256 && ARRAYW != 208)
            goto tryagain;
        // ARRAYH=80;
    }
    GLCD_Clear(DEMO_COLOR);
    arrayw = ARRAYW;
    arrayh = ARRAYH;
    totalpix = TOTALPIX;

    // memory buffers
    sprintf(IRAM1, "P5 \n%03d %03d\n255\n", ARRAYW, ARRAYH);
    fpimage = IRAM1+16;
    memset(Memory, 0, MSC_HeaderSize);
    p = (unsigned char *)DiskImage;

    while(1) {
        n = 0;
        for (i = 0; i<4; i++)
            n = (n << 8) | *p++;
        if (n == 0xffffffff)
            break;
        for (i = 0; i<16; i++)
        Memory[n++] = *p++;
        if (n > MSC_HeaderSize)
            break;
    }

    FP_softreset();
    FP_initscan();
    FP_init(config);
    key = 0;
    n = DEFAULTMODE;
    cbuf = 0;
    cnt = 0;
    bar = '/';
    offsx = 0;
    offsy = 0;
    whitelvl = 128;
    while (1) {
        if (n == LASTMODE) {
            key = 0;
            n = 1;
        }
        switch (n) {
            case CHECK: GLCD_DisplayString (12, 3, 1, "Check"); break;
            case ACTIVE: GLCD_DisplayString (12, 3, 1, "Active"); break;
            case PASSIV: GLCD_DisplayString (12, 3, 1, "Passive"); break;
            case CALIB_FF: GLCD_DisplayString (12, 3, 1, "Calibr"); break;
            case ENCRYPT: GLCD_DisplayString (12, 3, 1, "Encrypt"); break;
            case M5: GLCD_DisplayString (12, 3, 1, "MidianF"); break;
            case M5C: GLCD_DisplayString (12, 3, 1, "MidFCal"); break;
            default: break;
        }
        bar=(bar=='/')?'\\':'/';
        cnt=(cnt == 99)? 0: cnt+1;

        gain = config->Reg6&7;
        offs = config->Reg5&127;
        sprintf(lcdmsg,"%c %dx%d %d %02d%cG%2d F%3d UF%3d",modecode[n],ARRAYW,ARRAYH,key,cnt,bar,gain,offs,useroffs);
        GLCD_DisplayString(0,0,1,lcdmsg);
        //DBG_log(lcdmsg, 0);
        sprintf(lcdmsg, "%02x", FP_status());
        GLCD_DisplayString(0,LastCol-2,1,lcdmsg);

        // checking mode
        if (n == CHECK) {
            FP_init(config);
            FP_readimage(fpimage);
            FP_histogram();
            normalize(histogram);
            GLCD_Bitmap_Crop (24, 24, ARRAYW, ARRAYH, 
                        (ARRAYW>192)?192:ARRAYW, (ARRAYH>192)?192:ARRAYH, offsx, offsy, fpimage);
            GLCD_Histo (230, 64, 65, 128, histogram);
            sprintf(lcdmsg, "Mean%5.1f Var%6.2f HL%3d/%3d sp%3d ", (float)fp_mean/256.,(float)fp_variance/256., fp_hi, fp_lo, fp_hi-fp_lo);
            GLCD_DisplayString (LastRow, 0, 1, lcdmsg);

            // adjust offset?
            i=get_offs();
            offs=key_adj(get_offs(), 0, 127);
            if (i != offs)
                set_offs(offs);
        }

        // passive mode
        if (n == PASSIV) {
            if (auto_offs)
                FP_auto(fpimage,-1,autogain); // auto offs/gain 
            FP_init(config);
            FP_readimage(fpimage);
            FP_histogram();
            FP_filter(fpimage);
            normalize(histogram);
            GLCD_Bitmap_Crop (24, 24, ARRAYW, ARRAYH, 
                        (ARRAYW>192)?192:ARRAYW, (ARRAYH>192)?192:ARRAYH, offsx, offsy, fpimage);
            GLCD_Histo (230, 64, 65, 128, histogram);
            sprintf(lcdmsg, "Mean%5.1f Var%6.2f HL%3d/%3d sp%3d ", (float)fp_mean/256.,(float)fp_variance/256., fp_hi, fp_lo, fp_hi-fp_lo);
            GLCD_DisplayString (LastRow, 0, 1, lcdmsg);

            // adjust offset?
            i=get_offs();
            offs=key_adj(get_offs(), 0, 127);
            if (i != offs) {
                set_offs(offs);
                auto_offs = 0;
            }
        }

        // new active mode
        if (n == ACTIVE) {
            FP_readimageA(fpimage, scanN, whitelvl);
            GLCD_Bitmap_Crop (24, 24, ARRAYW, ARRAYH, 
                        (ARRAYW>192)?192:ARRAYW, (ARRAYH>192)?192:ARRAYH, offsx, offsy, fpimage);
            FP_histogram();
            normalize(histogram);
            GLCD_Histo (230, 64, 65, 128, histogram);
            sprintf(lcdmsg, "Mean%5.1f Var%5.2f HL%3d/%3d me%3d %3d", (float)fp_mean/256.,(float)fp_variance/256., fp_hi, fp_lo, fp_med, fp_cover);
            GLCD_DisplayString (LastRow, 0, 1, lcdmsg);
            //sprintf(lcdmsg, "span=%3d", fp_hi-fp_lo);
            //GLCD_DisplayString (3, 29, 1, lcdmsg);

            // adjust white level?
            i=key_adj(whitelvl, 0, 255);
            if (i != whitelvl)
                whitelvl = i;
        }

        // full-frame calibration
        // if the sensor is too big (256x360), skip this mode
        // in this mode: "ENTER" re-captures the reference frame
        //               "LEFT" followed by "RIGHT" invokes the menu
        if (n == CALIB_FF) {
            static int tar=0;
            static int t0=0;
            static int oldkey=0, newkey=0;

            if (totalpix > 64*1024) { // do we have enough memory?
                key=0;
                n =n+1;
                continue;
            }
            cbuf = fpimage+totalpix; // the reference frame

            if ((fp_hi-fp_lo < EMPTY_IMAGE_SPAN && fp_variance < EMPTY_IMAGE_VAR && ++i==10) || key == KEY_ENTER) { // span is less than 10!!!
                tar=FP_auto(cbuf,128,0);
                FP_init(config);
                FP_readimage(cbuf);
                FP_histogram();
                refmean=fp_mean>>8;
                if (key == KEY_ENTER) {
                    key = 0;
                    auto_offs = 1;
                }
            } else {
                if (auto_offs)
                    tar=FP_auto(fpimage,-1,0);
                FP_init(config);
                FP_readimageC (cbuf, refmean, fpimage, tar, scanN);
                GLCD_Bitmap_Crop (24, 24, ARRAYW, ARRAYH, 
                            (ARRAYW>192)?192:ARRAYW, (ARRAYH>192)?192:ARRAYH, offsx, offsy, fpimage);
                FP_histogram();
                normalize(histogram);
                GLCD_Histo (230, 64, 65, 128, histogram);
                sprintf(lcdmsg, "Mean%5.1f Var%6.2f HL%3d/%3d sp%3d %d%d", (float)fp_mean/256.,(float)fp_variance/256., fp_hi, fp_lo, fp_hi-fp_lo, oldkey, newkey);
                GLCD_DisplayString (LastRow, 0, 1, lcdmsg);
            }
            if (key != 0) {
                oldkey = newkey;
                newkey = key;
            }
            t0=key_adj(tar, 0, 255);
            if (t0 != tar) {
                auto_offs = 0;
                tar = t0;
            }
            // to allow menu 
            if (oldkey == KEY_LEFT && newkey == KEY_RIGHT) {
                key = 100;
                oldkey = 0;
            }
        }

        // show register and status
        if (n == SHOWREG) {
            show_state(1);
        }

        // show OTP content
        if (n == SHOWOTP) {
            show_otp(1);
            //if (key == KEY_RIGHT) {
            //    test_otp();
            //    key = 0;
            //}
        }

        // encrypted data
        if (n == ENCRYPT) {
            unsigned char otprd[32];
            unsigned char *ptr;
            unsigned char rd,sr0;

            if (arrayw < 120 || arrayh < 120) {
                key=0;
                n++;
                continue;
            }
            FP_auto(fpimage,128,0);
            sr0=config->Reg0;
            config->Reg0 &= 0xf0;   // set fast clock
            config->RegB = setbit(config->RegB, 4, 1, 1);  // enable encrypt

            FP_readotp(otprd);

            ptr = fpimage;
            cnt = totalpix;
    	    fpdecode(otprd+21, 0);
            FP_init(config);

            // init OTP
            SPI_SSEL(0);
	        SPI_sr(0x04);
	        SPI_SSEL(1);
	        delay(20);

	        // scan command
	        SPI_SSEL(0);
	        SPI_sr(0x01);
            //delay(100);

            SPI_sr(0x03);                
            while (1)
                if (SPI_sr(0x03)&4)     // wait until FIFO is not empty
                    break;
            SPI_SSEL(1);

        	// skip 1 byte of encrypted data
        	SPI_SSEL(0);
        	SPI_sr(0x02);
        	*ptr = SPI_sr(0x02);
        	fpdecode(ptr, 1);
            while (cnt-- > 0)
    		    *ptr++ = SPI_sr(0x02);
        	SPI_SSEL(1);
            // decrypt data
	        fpdecode(fpimage, totalpix);

            GLCD_Bitmap_Crop (24, 24, ARRAYW, ARRAYH, 
                    (ARRAYW>192)?192:ARRAYW, (ARRAYH>192)?192:ARRAYH, offsx, offsy, fpimage);

            rd=FP_status();
            if ((rd & 0x01)==0) {
                sprintf(lcdmsg, "FIFO underrun", rd);
                GLCD_DisplayString (13, 0, 1, lcdmsg);
                pause();
            }

            // clean up
            config->Reg0 = sr0;
            config->RegB = setbit(config->RegB, 4, 1, 0);
            FP_softreset();
        }

        // 5 line median filter
        if (n == M5) {
            if (TOTALPIX > (65536*2-32)/5) {
                n++;
                continue;
            }
            FP_init(config);
            FP_readimageM5(fpimage);
            FP_histogram();
            FP_filter(fpimage);
            normalize(histogram);
            GLCD_Bitmap_Crop (24, 24, ARRAYW, ARRAYH, 
                        (ARRAYW>192)?192:ARRAYW, (ARRAYH>192)?192:ARRAYH, offsx, offsy, fpimage);
            GLCD_Histo (230, 64, 65, 128, histogram);
            sprintf(lcdmsg, "Mean%5.1f Var%6.2f HL%3d/%3d sp%3d ", (float)fp_mean/256.,(float)fp_variance/256., fp_hi, fp_lo, fp_hi-fp_lo);
            GLCD_DisplayString (LastRow, 0, 1, lcdmsg);

            // adjust offset?
            i=get_offs();
            offs=key_adj(get_offs(), 0, 127);
            if (i != offs)
                set_offs(offs);
        }

        // 5 line median filter with calibration
        if (n == M5C) {
            static int tar=0;
            static int t0=0;
            static int oldkey=0, newkey=0;

            if (TOTALPIX > (65536*2-32)/6) { // do we have enough memory?
                n++;
                continue;
            }
            if (cbuf==0 || key == 101) { // span is less than 10!!!
                cbuf = fpimage+totalpix*5; // the reference frame
                //tar=FP_auto(cbuf,128,0);
                FP_init(config);
                FP_readimageM5(fpimage);
                FP_histogram();
                refmean=fp_mean>>8;
                if (key == 101) {
                    key = 0;
                    auto_offs = 1;
                }
                memcpy(cbuf, fpimage, totalpix);
            } else {
                //if (auto_offs)
                //    tar=FP_auto(fpimage,-1,0);
                FP_init(config);
                FP_readimageM5C (cbuf, refmean, fpimage, tar, scanN);
                GLCD_Bitmap_Crop (24, 24, ARRAYW, ARRAYH, 
                            (ARRAYW>192)?192:ARRAYW, (ARRAYH>192)?192:ARRAYH, offsx, offsy, fpimage);
                FP_histogram();
                normalize(histogram);
                GLCD_Histo (230, 64, 65, 128, histogram);
                sprintf(lcdmsg, "Mean%5.1f Var%6.2f HL%3d/%3d sp%3d %d%d", 
                        (float)fp_mean/256.,(float)fp_variance/256., fp_hi, fp_lo, fp_hi-fp_lo, oldkey, newkey);
                GLCD_DisplayString (LastRow, 0, 1, lcdmsg);
            }
            if (key != 0) {
                oldkey = newkey;
                newkey = key;
            }
            t0=key_adj(tar, 0, 255);
            if (t0 != tar) {
                auto_offs = 0;
                tar = t0;
            }
            // to allow menu 
            if (oldkey == KEY_LEFT && newkey == KEY_RIGHT) {
                key = 100;
                oldkey = 0;
            }
            // adjust offset?
            i=get_offs();
            offs=key_adj(get_offs(), 0, 127);
            if (i != offs)
                set_offs(offs);
            // switch mode?
            if (key == KEY_ENTER)
                key = 101;
            if (key == KEY_NEXT) {
                key = 0;
                n = M5;
            }
        }

        // detect mode
        if (n == DETECT) {
            GLCD_DisplayString (4, 0, 1, " Detect Mode ... ");
            sprintf(lcdmsg, "%d", FP_intr());
            GLCD_DisplayString (4, 17, 1, lcdmsg);
            
            FP_detst();
            sprintf(lcdmsg, "lvl=%4d cnt=%4d", fp_lvl, fp_cnt);
            GLCD_DisplayString (6, 0, 1, lcdmsg);
            
            delay(100);
        }

        if ((key == KEY_ENTER && n != CALIB_FF) || key == 100) {
            settings_menu();
            key = 0;
            GLCD_Clear(DEMO_COLOR);
        }

        if (key == KEY_ESC) {
          key = 0;
          if (n == DETECT) {
              show_state(1);
            while (1) {
                if (key == KEY_ESC) {
                    GLCD_Clear(DEMO_COLOR);
                    key = 0;
                    break;
                }
                delay(1000);
            }
          } else {
            usbd_init();
            usbd_connect(__TRUE);

            // show image quality stuff
            //imagechk (fpimage, ARRAYW, ARRAYH, 0, 1);
            //GLCD_Clear(DEMO_COLOR);
            //dispstat ();
               
            while (1) {
                if (key == KEY_ESC) {
                    GLCD_Clear(DEMO_COLOR);
                    key = 0;
                    break;
                }
                delay(1000);
            }
            usbd_init();
            usbd_connect(__FALSE);
            bump_filename();
            SPI_init();
          }
        }

        if (key == KEY_NEXT) {
            if (n == DETECT)
                FP_initscan();

            if (++n == LASTMODE)
                n = 1;
            key = 0;
            auto_offs = 1;
            GLCD_Clear (DEMO_COLOR);

            if (n == CALIB_FF)
                key = KEY_ENTER;

            if (n == DETECT) {
                FP_initdetect();
                FP_init(config);
            }
        }

nextdir:
        if (ARRAYW > 192) {
            if (dir==1) {
                if (offsx != (ARRAYW-192))
                    offsx += 8;
                else
                    dir = 2;
            }
    
            if (dir==2) {
                if (offsy != (ARRAYH-192))
                    offsy += 8;
                else
                    dir = 3;
            }
    
            if (dir==3) {
                if (offsx != 0)
                    offsx -= 8;
                else
                    dir = 4;
            }
    
            if (dir==4) {
                if (offsy != 0)
                    offsy -= 8;
                else {
                    dir = 1;
                    goto nextdir;
                }
            }
        }
    }
}
