
import spidev
import time
from read_write import PN7462_read_write
from cl_func import pos_func
import enum
# Using enum class create enumerations
class Status(enum.Enum):
  E_STS_NO_EVENT =0
  E_BANKING_CARD_INSERTION_EVENT_TYPEA=1
  E_BANKING_CARD_INSERTION_EVENT_TYPEB=2
  E_BANKING_CARD_INSERTION_EVENT_CT=3
  E_NONBANKING_CARD_INSERTION_EVENT_TYPEA=4
  E_NONBANKING_CARD_INSERTION_EVENT_TYPEB=5
  E_CARD_REMOVAL_EVENT=6
  E_SAM_INSERTION_EVENT=7
  E_SAM_REMOVAL_EVENT=8
  E_RF_COM_ERR_EVENT=9
  E_SYS_EXCEPTION_EVENT=10




PN7462 = PN7462_read_write (spi = spidev.SpiDev() ,chip_select=18,busy=25,speed=5000,bus=1,channel=0)


def main():

    # Open file descriptor for
    # spi device 0 using the CE0 pin for chip select
  while True:
    print("start")
    time.sleep(1)
    pos_app = pos_func(PN7462)
    error,out,len = pos_app.get_config_cmd()
    if(error < 0):
        print("error get configuration")
    else :

        sw1sw2 = (out[len-2] << 8) | out[len-1]
        print("SW2SW2",hex(sw1sw2))
        if (sw1sw2 == 0x9000):
            print("get configuration success ")
            if(out[0] ==0x01):
                print("Contactless card supported")
            if(out[1] ==0x02):
                print("Contact card supported")
# start polling command

    error,out,len =pos_app.enable_polling_cmd()
    if(error < 0):
        print("error enable polling")
    else :
        sw1sw2 = (out[len-2] << 8) | out[len-1]
        print("SW2SW2",hex(sw1sw2))
    if (sw1sw2 == 0x9000):
        print("Please Tap the card.... ")

# get status of poll
    time.sleep(0.5)
    while True:
        time.sleep(0.02)
        error,out,len =pos_app.get_status_cmd()
        if(error < 0):
            print("error getting the status")
            break
        else :
            sw1sw2 = (out[len-2] << 8) | out[len-1]
            if (sw1sw2 == 0x9000):
                if(0x01 == out[0]):
                    print("card_detected")
                    break

    error,out,len =pos_app.get_uid()
    if(error < 0):
        print("error getting the status")
    else :
        sw1sw2 = (out[len-2] << 8) | out[len-1]
        print("SW2SW2",hex(sw1sw2))
    if (sw1sw2 == 0x9000):
        print("status success ")
        print("UID",out[0:len-2])

    error,out,len =pos_app.get_atr()
    if(error < 0):
        print("error getting the status")
    else :
        sw1sw2 = (out[len-2] << 8) | out[len-1]

        if (sw1sw2 == 0x9000):
            print("ATR",out[0:len-2])

    error,out,len =pos_app.deactivate_card()
    if(error < 0):
        print("error getting the status")
    else :
        sw1sw2 = (out[len-2] << 8) | out[len-1]
        print("SW2SW2",hex(sw1sw2))
    if (sw1sw2 == 0x9000):
        print("Remove the card  ")

    print("end of test ")
    time.sleep(2)



if __name__ == "__main__":
    main()

