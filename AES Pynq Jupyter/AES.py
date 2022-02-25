
# coding: utf-8

# The first stage to running an encryption is to get the serial and base setup. This configures the serial, the output pins for the trigger, and the buttons and switches.

# In[1]:


import sys
get_ipython().system('{sys.executable} -m pip install pyserial')


# In[1]:


print("hello world")


# In[2]:


import time
import serial
from time import sleep

from pynq.overlays.base import BaseOverlay
from pynq.lib.arduino import arduino_io

base = BaseOverlay('base.bit')

# trigger for the pynq on arduino pins a0 and a1
trigger_out = arduino_io.Arduino_IO(base.iop_arduino.mb_info, 14, 'out')
trigger_in = arduino_io.Arduino_IO(base.iop_arduino.mb_info, 15, 'in')

key = b'aesEncryptionKey'  # can change this


# In[3]:


# pull in the customlibrary
get_ipython().magic('run pyaes.ipynb')


# In[4]:


led0 = base.leds[0] #Corresponds to LED LD0
led1 = base.leds[1] #Corresponds to LED LD1
led2 = base.leds[2] #Corresponds to LED LD2
led3 = base.leds[3] #Corresponds to LED LD3


# In[5]:


sw0 = base.switches[0] #Corresponds to SW0
sw1 = base.switches[1] #Corresponds to SW1


# In[6]:


btn0 = base.buttons[0] # button 0 hopefully
btn1 = base.buttons[1]
btn2 = base.buttons[2]
btn3 = base.buttons[3]


# In[7]:


class CWSerial:
    ACK = b"z00" # 'z00'
    READ = b"r" #'r'
    def __init__(self, device):
        self.device = device
        self.connection = None

    def configure(self):
        self.connection = serial.Serial(
            self.device, 38400, timeout=None, bytesize=serial.EIGHTBITS, parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE, xonxoff=False)
        time.sleep(1)

    def read(self, msg_size=1):
        data = self.connection.read(msg_size)
        return data

    def readline(self):
        data = self.connection.readline().strip()
        return data

    # pass write a byte array with cmd and data and newline
    def write(self, cmd):
        print(f"writing {cmd}")
        self.connection.write(cmd)
        



# In[8]:


print("Welcome to the pynq z2 board test")
mode = 0 # mode 0 is regular input, mode 1 is file input


# The setup is now complete and we can begin encryptions.

# In[9]:


def encrypt(key, plaintext):
    encrypter = Encrypter(AESModeOfOperationECB(key))
    ciphertext = encrypter.feed(plaintext)
    ciphertext += encrypter.feed()

    #            print( repr(ciphertext))
#     for letter in ciphertext:
#         print('{:0>2}'.format(str(hex(letter))[2:]), end='')
    return ciphertext


# In[10]:


# assumes type bytes, bytes for arguments
def make_cmd(cmd, byte_data=b''):
    buffer = cmd + byte_data + b'\n'
    return buffer

def format_bytestr_as_hexstr(text):
    hexform = ''
    for letter in text:
        hexform += ('{:0>2}'.format(str(hex(letter))[2:]))
    return bytes(hexform, 'utf-8')

def format_hexstr_as_bytestr(hexstr):
    return bytes.fromhex(hexstr.decode('utf-8'))


# In[ ]:


# switch based LED toggling for test
data= ''
key = b'aesEncryptionKey'
cw_com = CWSerial("/dev/ttyUSB0")
cw_com.configure()

print("Configured Pynq; can start sending data")
while(True):  # All the code below while(True) runs forever
    # display help
    if btn0.read():
        print("SW1 controls whether lights and encryption or cw encryption")
        print("In encryption mode:")
        print("\t BTN0 resets the data")
        print("\t BTN1 orders input of data\n")
        print("\t BTN2 allows key input (padded to 16 characters)")
        print("\t BTN3 does encryption")

    if not sw1.read():
        led2.toggle()
        led3.toggle()
        if btn1.read():
            led1.toggle()
            led0.toggle()
            trigger_out.write(1)
            data = input()
            x = encrypt(key, str.encode(data))
            trigger_out.write(0)
            print(x)
            
    # run the input read and encryption to the cw
    else:
        #b = mystring.encode('utf-8')
        
        inp = cw_com.readline()
        print(inp)
        
        if inp.decode("utf-8")[0] == 'k':
            key = format_hexstr_as_bytestr(inp[1:])
            cw_com.write(make_cmd(CWSerial.ACK))
            print('received key')
            inp = cw_com.readline()
            
        if inp.decode("utf-8")[0] == 'p':
            data = format_hexstr_as_bytestr(inp[1:])
#            cw_com.write(cw_com.make_cmd(cw_com.ACK))
            print("received plaintext")

        if key and data:
            print(f"ready to encrypt  {data} with key {key}")
            trigger_out.write(1)
            ciphertext = encrypt(key, data)
            ciphertext=ciphertext[:16]

            cw_com.write(make_cmd(CWSerial.READ, format_bytestr_as_hexstr(ciphertext)))
            cw_com.write(make_cmd(CWSerial.ACK))

            trigger_out.write(0)
            print(f"encrypted:  {ciphertext}\n")


# In[35]:


# try reducing clock

