#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <getopt.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <linux/spi/spidev.h>
#include <string.h>
#include <errno.h>

#define SPI_DEV "/dev/spidev1.0"
#define NFC_IRQ	(85)

static unsigned int mode;
static unsigned int delay;
static unsigned int speed =  1000000;
static unsigned int bits = 8;
static unsigned int fd = 0;
static unsigned char tx_buf[20];
static unsigned char rx_buf[20];

void spi_dup(char *tx_buf,char *rx_buf,int len);
void spi_tx(char *tx_buf,int len);
void spi_rx(char *rx_buf , int len);

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
        printf("can't send spi dup message \r\n");

}

unsigned char SPI_sr(unsigned char c)
{

    unsigned char tx_buf[20];
    //unsigned char rx_buf[20];

    tx_buf[0] =  c;
    tx_buf[1] =  0x00;
    char buf[2];
    memset(buf,0x00,sizeof(buf));
    //spi_tx(tx_buf, 2);
    spi_dup((char*)tx_buf, buf, 2);

    return buf[1];
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
    if (ret < 1) {
        printf("can't send spirx message \r\n");
		perror("");
	}

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
	perror("");
    if (ret < 1)
        printf("can't send spitx  message \r\n");

}

int gpio_export(int gpio)
{
	char result[256];
	memset (result, 0x0, sizeof(result));

	// Export the desired pin by writing to /sys/class/gpio/export
    sprintf(result, "%d", gpio);
    printf("GPIO num is %s", result);
    int fd = open("/sys/class/gpio/export", O_WRONLY);
    if (fd == -1) {
        printf("Unable to open /sys/class/gpio/export");
        return 1;
    }

    if (write(fd, result, strlen(result)) != 2) {
        printf("Error writing to /sys/class/gpio/export");
        return 1;
    }

    close(fd);

    // Set the pin to be an output by writing "out" to /sys/class/gpio/gpio24/direction
    sprintf(result, "/sys/class/gpio/gpio%d/direction", gpio);
    fd = open(result, O_WRONLY);
    if (fd == -1) {
        printf("Unable to open %s\n", result);
        return 1;
    }

    if (write(fd, "out", 3) != 3) {
        printf("Error writing to %s", result);
        return 1;
    }

    close(fd);

	return 0;
}

int gpio_write(int gpio, char value)
{
	char result[50];
	int fda = 0;

	memset (result, 0x0, sizeof(result));
    sprintf(result, "/sys/class/gpio/gpio%d/value", gpio);
    fda = open(result, O_WRONLY);
    if (fda <= 0)
	{
        printf("gpio_write: Unable to open %s\n", result);
        return 1;
    }

    if (write(fda, &value, 1) != 1)
	{
        printf("gpio_write: Error writing to %s\n", result);
		close(fda);
        return 1;
    }

	close(fda);

	return 0;
}

int gpio_read(int gpio)
{
	char value = 5;
	char result[50];
	int fda = 0;
	int ret = 0;

	memset (result, 0x0, sizeof(result));
    sprintf(result, "/sys/class/gpio/gpio%d/value", gpio);
    fda = open(result, O_RDONLY);
    if (fda == -1)

	{
        printf("gpio_read: Unable to open %s\n", result);
        return 1;
    }

    if (!read(fda, &value, 1))
	{
        printf("gpio_read: Error writing to %s", result);
		close(fda);
        return 1;
    }
	//printf("Read <%s> gpio %d; ret = %d\n ",result, value, ret);

	close(fda);
	return value;
}


int spi_read_write(char *Command, int wlen, char *response, int rlen)
{
	int i = 0;
	//printf ("Tx = %s\n", Command);
	printf ("Tx = ");
	for (i=0;i<wlen;i++)
	{
		printf("0x%x ", Command[i]);
	}
	printf("\n");
	spi_tx(Command, wlen);
	sleep (1);
#if 0
	while (1)
	{
		if (gpio_read(NFC_IRQ) == 1)
		{
			printf("IRQ is high\n");
			break;
		}
	}
#endif
	printf ("Before Rx = 0x");

	for (i=0;i<rlen;i++)
	{
		printf("%x", response[i]);
	}
	printf("\n");
	spi_rx(response, rlen);
	//printf ("Rx = %s\n", response);
	printf ("Rx = 0x");

	for (i=0;i<rlen;i++)
	{
		printf("%x", response[i]);
	}
	printf("\n");

	return 0;
}

int get_config_cmd ()
{
	memset (tx_buf, 0x00, sizeof (tx_buf));
	memset(rx_buf, 0x0, sizeof(rx_buf));

	tx_buf[0] = 0x00;
	tx_buf[1] = 0x05;
	tx_buf[2] = 0x00;
	tx_buf[3] = 0x00;
	tx_buf[4] = 0x00;
	tx_buf[5] = 0xFF;
	tx_buf[6] = 0xF8;
	tx_buf[7] = 0x00;
	tx_buf[8] = 0x00;
	tx_buf[10] = 0x00;

	spi_read_write((char*)tx_buf, 10, (char *)rx_buf, 20);

	return 0;
}

int enable_polling_cmd()
{
	memset (tx_buf, 0x00, sizeof (tx_buf));
	memset(rx_buf, 0x0, sizeof(rx_buf));

	tx_buf[0] = 0x00;
	tx_buf[1] = 0x05;
	tx_buf[2] = 0x00;
	tx_buf[3] = 0x00;
	tx_buf[4] = 0x00;
	tx_buf[5] = 0xFF;
	tx_buf[6] = 0xF8;
	tx_buf[7] = 0x07;
	tx_buf[8] = 0x01;
	tx_buf[10] = 0x00;

	spi_read_write((char *)tx_buf, 10, (char *)rx_buf, 20);

	return 0;
}

int get_status_cmd()
{
	memset (tx_buf, 0x00, sizeof (tx_buf));
	memset(rx_buf, 0x0, sizeof(rx_buf));

	tx_buf[0] = 0x00;
	tx_buf[1] = 0x05;
	tx_buf[2] = 0x00;
	tx_buf[3] = 0x00;
	tx_buf[4] = 0x00;
	tx_buf[5] = 0xFF;
	tx_buf[6] = 0xF8;
	tx_buf[7] = 0x02;
	tx_buf[8] = 0x00;
	tx_buf[10] = 0x00;

	spi_read_write((char *)tx_buf, 10, (char *)rx_buf, 20);

	return 0;
}


int  get_uid()
{
	memset (tx_buf, 0x00, sizeof (tx_buf));
	memset(rx_buf, 0x0, sizeof(rx_buf));

	tx_buf[0] = 0x00;
	tx_buf[1] = 0x05;
	tx_buf[2] = 0x00;
	tx_buf[3] = 0x00;
	tx_buf[4] = 0x00;
	tx_buf[5] = 0xFF;
	tx_buf[6] = 0xF8;
	tx_buf[7] = 0x0C;
	tx_buf[8] = 0x00;
	tx_buf[10] = 0x00;

	spi_read_write((char *)tx_buf, 10, (char *)rx_buf, 20);
	return 0;
}


int get_atr()
{
	memset (tx_buf, 0x00, sizeof (tx_buf));
	memset(rx_buf, 0x0, sizeof(rx_buf));

	tx_buf[0] = 0x00;
	tx_buf[1] = 0x05;
	tx_buf[2] = 0x00;
	tx_buf[3] = 0x00;
	tx_buf[4] = 0x00;
	tx_buf[5] = 0xFF;
	tx_buf[6] = 0xF8;
	tx_buf[7] = 0x03;
	tx_buf[8] = 0x00;
	tx_buf[10] = 0x00;

	spi_read_write((char *)tx_buf, 10, (char *)rx_buf, 20);
	return 0;
}


int sel_PPSC_command()
{
	return 0;
}

int sel_appl_cmd()
{
	return 0;
}

int deactivate_card()
{
	memset (tx_buf, 0x00, sizeof (tx_buf));
	memset(rx_buf, 0x0, sizeof(rx_buf));

	tx_buf[0] = 0x00;
	tx_buf[1] = 0x05;
	tx_buf[2] = 0x00;
	tx_buf[3] = 0x00;
	tx_buf[4] = 0x00;
	tx_buf[5] = 0xFF;
	tx_buf[6] = 0xF8;
	tx_buf[7] = 0x04;
	tx_buf[8] = 0x00;
	tx_buf[10] = 0x00;

	spi_read_write((char *)tx_buf, 10, (char *)rx_buf, 20);
	return 0;
}

int main(int argc, char *argv[])
{
	int ret = 0;

	do {
		fd = open(SPI_DEV, O_RDWR);
		if (fd < 0) {
			printf("can't open device");
			break;
		}

		/*
		 * spi mode
		 */
		ret = ioctl(fd, SPI_IOC_WR_MODE, &mode);
		if (ret == -1) {
			printf("can't set spi mode");
			break;
		}

		ret = ioctl(fd, SPI_IOC_RD_MODE, &mode);
		if (ret == -1) {
			printf("can't get spi mode");
			break;
		}

		/*
		 * bits per word
		 */
		ret = ioctl(fd, SPI_IOC_WR_BITS_PER_WORD, &bits);
		if (ret == -1) {
			printf("can't set bits per word");
			break;
		}

		ret = ioctl(fd, SPI_IOC_RD_BITS_PER_WORD, &bits);
		if (ret == -1) {
			printf("can't get bits per word");
			break;
		}

		/*
		 * max speed hz
		 */
		ret = ioctl(fd, SPI_IOC_WR_MAX_SPEED_HZ, &speed);
		if (ret == -1) {
			printf("can't set max speed hz");
			break;
		}

		ret = ioctl(fd, SPI_IOC_RD_MAX_SPEED_HZ, &speed);
		if (ret == -1) {
			printf("can't get max speed hz");
			break;
		}

	} while (0);

	printf("spi mode: %d\n", mode);
	printf("bits per word: %d\n", bits);
	printf("max speed: %d Hz (%d KHz)\n", speed, speed/1000);

	get_config_cmd();
	enable_polling_cmd();


	return 0;
}
