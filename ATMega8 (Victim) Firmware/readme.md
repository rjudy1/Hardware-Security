Building firmware for victim
======================================

Uploading the hex file
-------------------
Follow the instructions in the attached *Uploading to ATMEGA8 with ArduinoISP.pdf* file.

Before doing step 4, part D, delete the existing .hex file in the debug folder of the microchip studio 
project and copy the hex file that **make** made into the debug folder.

Rename the hex file so it matches the hex file that was deleted.

Doing this will cause the *deploy* command that is done in step 4, part D to deploy your hex file to the target instead of the project's hex file,
as deploy doesn't verify the hex file before uploading it.