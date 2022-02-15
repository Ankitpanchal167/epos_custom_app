'''
Created on 03-Sep-2020

@author: joshi
'''



import time
#import RPi.GPIO as GPIO


#def singleton(cls):
#    return cls()

#@singleton

class PN7462_read_write() :

    '''
    '''
    def __init__(self, spi,chip_select,busy,speed,bus,channel):
        self.spi = spi
        self.chip_select = chip_select
        #GPIO.setmode(GPIO.BCM)
        #GPIO.setwarnings(0)
        #GPIO.setup(busy,GPIO.IN)
        #GPIO.setup(self.chip_select,GPIO.OUT)
        self.spi.open(bus,channel)
        self.spi.max_speed_hz =speed
        self.busy = busy


    def write(self, data):
        ''' assert SPI chip select '''
        #GPIO.output(self.chip_select,GPIO.LOW)
        ''' send the write header '''
        data1=self.spi.xfer2( data)
        #GPIO.output(self.chip_select,GPIO.HIGH)

        return data1

    def read(self):
        error =0
        ''' assert SPI chip select '''
        buf = bytearray(256)
        #GPIO.output(self.chip_select,GPIO.LOW)
        ''' send the write header '''
        buf[0] =0xFF
        ''' send the read header first '''
        buf[0:5]=self.spi.xfer2( buf[0:5])
        len = buf[1] | (buf[2] << 8)

        if(len > 200):
            error=-1
            len=200
        else:
            buf[0] =0xFF
            buf[0:len+1]=self.spi.xfer2( buf[0:len+1])

        #GPIO.output(self.chip_select,GPIO.HIGH)
        return(error,buf[1:len+1],len)

    def read_write(self,data):
        self.write( data)
        time.sleep(1)
        #while True:
        #    if(GPIO.input(self.busy)==GPIO.LOW):
        #        break

        error,out,len=self.read()
        return error,out,len




