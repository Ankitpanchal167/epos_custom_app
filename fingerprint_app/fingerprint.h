/*----------------------------------------------------------------------------
 * fingerprint.h: fingerprint sensor driver header file
 * Written by FCL
 * Copyright SunASIC, Inc. 2017
 * Note(s):
*----------------------------------------------------------------------------*/

#ifndef _FINGERPRINT_H
#define _FINGERPRINT_H

typedef struct fpconfig {
    unsigned char   Reg0;  // reg0: DETDIV(4),OSCDIV(4)
    unsigned char   Reg1;  // reg1: RSTT(4), SAMPT(4)
    unsigned char   Reg2;  // reg2: ADC_ISEL(2), PGA_ISEL(2), BG_ISEL(2), ADCREF, LDOSUS
    unsigned char   Reg3;  // reg3: PSF_ISEL(2), SF_ISEL(2), VDDR_ISEL(2), OSC(ISEL(2)
    unsigned char   Reg4;  // reg4: SELI(2),SELR(3),VDETSEL(3)
    unsigned char   Reg5;  // reg5: ADCIOPT(1),OFFS(7)
    unsigned char   Reg6;  // reg6: --, ACONF(3), PGAGAIN(3)
    unsigned char   Reg7;  // reg7: SCANDELAY(4),CDSCPN(4)
    unsigned char   Reg8;  // reg8: DETCLK(2),DETTH(6)
    unsigned char   Reg9;  // reg9: CDSADJ(2),TRIM10K(3),TRI4M(3)
    unsigned char   RegA;  // regA: INVIO,LTEST,T1SEL(2),INVIO2,T2OE,T2SEL(2)
    unsigned char   RegB;  // regB: SUBSCAN,INVERT,ENDET,ENCRYP,ENPWR,ENADC,EN10K,EN4M
    unsigned char   RegC;  // regC: ---,RSTPAT(5)
    unsigned char   RegD;  // regD: OTPADDR
    unsigned char   RegE;  // regE: OTPWD
    unsigned char   RegF;  // regF: OTPCMD
} FPCONFIG;

extern FPCONFIG fpconfig0, fpconfig1, *config;

typedef struct fpstat {
    int mean;
    int variance;
    int hi;
    int lo;
    int med;
    int cover;
} FPSTAT;

extern FPSTAT fpstat;

#define fp_mean     (fpstat.mean)
#define fp_variance (fpstat.variance)
#define fp_hi       (fpstat.hi)
#define fp_lo       (fpstat.lo)
#define fp_med      (fpstat.med)
#define fp_cover    (fpstat.cover)

// basic and passive callables
//extern void     delay(int n);                                   // usec delay loop
extern void     FP_init (FPCONFIG *cfg);                        // initializing registers
extern void     FP_readconfig (unsigned char *s);               // read register content
extern int      FP_status(void);                                // read status
extern int      FP_intr(void);                                  // finger detect interrupt
extern void     FP_initotp (void);                              // initialize OTP
extern void     FP_detst(void);                                 // check detect status
extern void     FP_softreset (void);                            // software reset
extern void     FP_hardreset (void);                            // hard reset
extern void     FP_setoffs(int val);                            // set offset register
extern void     FP_readotp (unsigned char *s);                  // read OTP content
extern void     FP_chksize(unsigned int *w, unsigned int *h);   // check sensor size
extern void     FP_readimage (unsigned char *buff);             // read image
extern void     FP_histogram (void);                            // calculate histogram
extern void     FP_initscan(void);                              // set to scan mode
extern void     FP_initdetect(void);                            // set to finger detect mode
extern void     FP_fastmode(int fast);                          // fast mode
extern int      FP_auto(unsigned char *buff, int target, int autogain); // auto offset/gain
extern void     FP_getstat(FPSTAT *ptr);
extern void     fpdecode(unsigned char *buf, unsigned int cnt); // decrypt routine

// active driver
void FP_readimageA (unsigned char *buff, int enhance, int target);
int  FP_autoWhite (unsigned char *buff, int whitelvl);

extern unsigned int     ARRAYH, ARRAYW, TOTALPIX;               // actual size
extern unsigned int     arrayh, arrayw, totalpix;               // working copy
extern unsigned char    *fpimage;                               // image buffer
extern unsigned int     histogram[128];                         // statistic
// extern int              fp_mean, fp_variance;
// extern int              fp_hi, fp_lo, fp_med, fp_cover;         // image attributes
extern unsigned int     fp_lvl, fp_cnt;                         // finger detect status
extern float            unifv, unifh;                           // uniformity parameter

#define set_offs(x)     config->Reg5=(config->Reg5&0x80)|(x&0x7f)
#define set_gain(x)     config->Reg6=(config->Reg6&0xf8)|(x&0x07)
#define get_offs()      (config->Reg5 & 0x7f)
#define get_gain()      (config->Reg6 & 0x7)

#define setbit(reg, bit, mask, val) (((reg) & ~((mask) << (bit))) | ((val) << (bit)))

#endif /* _FINGERPRINT_H */
