#ifndef __SPI_H
#define __SPI_H

extern void spi_dup(char *tx_buf,char *rx_buf,int len);
extern void spi_tx(char *tx_buf,int len);
extern void spi_rx(char *rx_buf , int len);
extern void SPI_RST(unsigned char val);


extern unsigned char              SPI_sr(unsigned char byte);

#endif
