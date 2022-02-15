/*----------------------------------------------------------------------------
 * header file for A365
 * Written by FCL
 * Copyright SunASIC, Inc. 2017
*----------------------------------------------------------------------------*/

#define CENTR 126      // neutral gray
#define WHITE 220      // white level
#define TAEGET0 64426  // offset of target calculation (CENTR*256+256*(WHITE-CENTR)*V1/(V1-V0))
#define V0 15          // low bound of span/variance
#define V1 60          // high bound of span/variance
#define SLOPE  1477    // slop of fp_mean/offset (6.91*255)
#define GMAX 2.0       // maxgain (GMAX=1~3.5, 0/1,1/1.25,2/1.5,3/1.75,4/2.0,5/2.5,6/3.0,7/3.5)
#define D0  18         // param of gain-span curve
#define D1  50         // param of gain-span curve

// common settings:
//
// RegA -   0x0-: RESET input
//          0x2-: interrupt output using REST pin 
//          0x-f: active mode using TEST pin

#ifndef __FPCFG_H
#define __FPCFG_H

// configuration for capturing image
FPCONFIG fpconfig0 = {
    0x51,   // reg0: DETDIV(4),OSCDIV(4)
    0x28,   // reg1: RSTT(4), SAMPT(4)
    0x54,   // reg2: ADC_ISEL(2), PGA_ISEL(2), BG_ISEL(2), ADCREF, LDOSUS
    0x59,   // reg3: PSF_ISEL(2), SF_ISEL(2), VDDR_ISEL(2), OSC(ISEL(2)
    0x53,   // reg4: SELI(2),SELR(3),VDETSEL(3)
    0x32,   // reg5: ADCIOPT(1),OFFS(7)
    0x02,   // reg6: --, ACONF(3), PGAGAIN(3)
    0x20,   // reg7: SCANDELAY(4),CDSCPN(4)
    0x86,   // reg8: DETCLK(2),DETTH(6)
    0x20,   // reg9: CDSADJ(2),TRIM10K(3),TRI4M(3)
    0x0f,   // regA: INVIO,LTEST,T1SEL(2),INVIO2,T2OE,T2SEL(2)
    0x0f,   // regB: SUBSCAN,INVERT,ENDET,ENCRYP,ENPWR,ENADC,EN6K,EN4M
    0x16,   // regC: ---,RSTPAT(5)
    0x00,   // regD: OTPADDR
    0x43,   // regE: OTPWD
    0x01,   // regF: OTPCMD
};

//EI custom setting
#if 0
// configuration for finger detection mode
FPCONFIG fpconfig1 = {
    0xb0,   // reg0: DETDIV(4),OSCDIV(4)
    0x00,   // reg1: RSTT(4), SAMPT(4)
    0x00,   // reg2: ADC_ISEL(2), PGA_ISEL(2), BG_ISEL(2), ADCREF, LDOSUS
    0x00,   // reg3: PSF_ISEL(2), SF_ISEL(2), VDDR_ISEL(2), OSC(ISEL(2)
    0x54,   // reg4: SELI(2),SELR(3),VDETSEL(3)
    0x11,   // reg5: ADCIOPT(1),OFFS(7)
    0x00,   // reg6: --, ACONF(3), PGAGAIN(3)
    0x20,   // reg7: SCANDELAY(4),CDSCPN(4)
    0x15,   // reg8: DETCLK(2),DETTH(6)
    0x23,   // reg9: CDSADJ(2),TRIM10K(3),TRI4M(3)
    0x2f,   // regA: INVIO,LTEST,T1SEL(2),INVIO2,T2OE,T2SEL(2)
    0x2B,   // regB: SUBSCAN,INVERT,ENDET,ENCRYP,ENPWR,ENADC,EN6K,EN4M 
    0x16,   // regC: ---,RSTPAT(5)
    0x00,   // regD: OTPADDR
    0x03,   // regE: OTPWD
    0x01,   // regF: OTPCMD
};
#endif

#if 0
// configuration for finger detection mode
FPCONFIG fpconfig1 = {
    0xb0,   // reg0: DETDIV(4),OSCDIV(4)
    0x00,   // reg1: RSTT(4), SAMPT(4)
    0x00,   // reg2: ADC_ISEL(2), PGA_ISEL(2), BG_ISEL(2), ADCREF, LDOSUS
    0x00,   // reg3: PSF_ISEL(2), SF_ISEL(2), VDDR_ISEL(2), OSC(ISEL(2)
    0x54,   // reg4: SELI(2),SELR(3),VDETSEL(3)
    0x11,   // reg5: ADCIOPT(1),OFFS(7)
    0x00,   // reg6: --, ACONF(3), PGAGAIN(3)
    0x20,   // reg7: SCANDELAY(4),CDSCPN(4)
    0x09,   // reg8: DETCLK(2),DETTH(6)
    0x23,   // reg9: CDSADJ(2),TRIM10K(3),TRI4M(3)
    0x2f,   // regA: INVIO,LTEST,T1SEL(2),INVIO2,T2OE,T2SEL(2)
    0x2B,   // regB: SUBSCAN,INVERT,ENDET,ENCRYP,ENPWR,ENADC,EN6K,EN4M 
    0x16,   // regC: ---,RSTPAT(5)
    0x00,   // regD: OTPADDR
    0x03,   // regE: OTPWD
    0x01,   // regF: OTPCMD
};
#endif

//Biosec setting 
// configuration for finger detection mode
#if 1
FPCONFIG fpconfig1 = {
    0xb0,   // reg0: DETDIV(4),OSCDIV(4)
    0x00,   // reg1: RSTT(4), SAMPT(4)
    0x00,   // reg2: ADC_ISEL(2), PGA_ISEL(2), BG_ISEL(2), ADCREF, LDOSUS
    0x00,   // reg3: PSF_ISEL(2), SF_ISEL(2), VDDR_ISEL(2), OSC(ISEL(2)
    0x52,   // reg4: SELI(2),SELR(3),VDETSEL(3)
    0x33,   // reg5: ADCIOPT(1),OFFS(7)
    0x06,   // reg6: --, ACONF(3), PGAGAIN(3)
    0x20,   // reg7: SCANDELAY(4),CDSCPN(4)
//    0x09,   // reg8: DETCLK(2),DETTH(6)
    0x20,   // reg8: DETCLK(2),DETTH(6)
    0x23,   // reg9: CDSADJ(2),TRIM10K(3),TRI4M(3)
    0x2f,   // regA: INVIO,LTEST,T1SEL(2),INVIO2,T2OE,T2SEL(2)
    0x2B,   // regB: SUBSCAN,INVERT,ENDET,ENCRYP,ENPWR,ENADC,EN6K,EN4M 
    0x16,   // regC: ---,RSTPAT(5)
    0x00,   // regD: OTPADDR
    0x03,   // regE: OTPWD
    0x01,   // regF: OTPCMD
};

#endif

#endif
