import time
import serial

class CWSerial:
    def __init__(self, device):
        self.device = device
        self.connection = None

    def configure(self):
        self.connection = serial.Serial(
            self.device, 9600, timeout=5, bytesize=serial.EIGHTBITS, parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE, xonxoff=False)
        time.sleep(1)

    def read():
        return self.connection.readline().strip()


cw_com = CWSerial("/dev/ttyUSB0")
print(cw_com.read())


import time

from pynq.overlays.base import BaseOverlay
from pynq.lib.arduino import arduino_io

base = BaseOverlay('base.bit')

p1 = arduino_io.Arduino_IO(base.iop_arduino.mb_info, 14, 'out')
p2 = arduino_io.Arduino_IO(base.iop_arduino.mb_info, 15, 'in')

while (True):
    # should do encryption
    if p2.read():
        p1.write(1)
        sleep(.5)
        p1.write(0)
        encrypt(...)
        