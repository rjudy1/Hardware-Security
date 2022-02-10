import time
import serial


from pynq.overlays.base import BaseOverlay
from pynq.lib.arduino import arduino_io

base = BaseOverlay('base.bit')

trigger_out = arduino_io.Arduino_IO(base.iop_arduino.mb_info, 14, 'out')
trigger_in = arduino_io.Arduino_IO(base.iop_arduino.mb_info, 15, 'in')

class CWSerial:
    def __init__(self, device):
        self.device = device
        self.connection = None

    def configure(self):
        self.connection = serial.Serial(
            self.device, 38400, timeout=5, bytesize=serial.EIGHTBITS, parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE, xonxoff=False)
        time.sleep(1)

    def read():
        return self.connection.readline().strip()


cw_com = CWSerial("/dev/ttyUSB0")

while (True):
    # should do encryption
    if trigger_in.read():
        trigger_out.write(1)
        sleep(.5)
        trigger_out.write(0)
        data = cw_com.read()
        encrypt(key, str.encode(data))
        