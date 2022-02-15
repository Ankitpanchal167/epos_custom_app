/*----------------------------------------------------------------------------
 * fingerprint.h: fingerprint sensor driver header file
 * Written by FCL
 * Copyright SunASIC, Inc. 2017
 * Note(s):
*----------------------------------------------------------------------------*/

#ifndef _FINGERPRINT_CH
#define _FINGERPRINT_CH

#define EMPTY_IMAGE_SPAN 15
#define EMPTY_IMAGE_VAR 10*256

extern void FP_readimageC (unsigned char *refimg, unsigned int rmean, unsigned char *buff, int target, int nn);

#endif /* _FINGERPRINT_H */
