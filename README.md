# Hardware-Security
Home of the Hardware Security Senior Design Team 2021-2022

Team: Rachael Judy, Andrew Smith, Leslie Wallace :)


## How to Create the Project
Vivado->Create New Project

Add all .vhd files from src. Add the block diagram from src/design_1. Add prog_mem_content.vhd from test/C_Programs/program_name/

Add the xdc constraints file from the main directory. Currently using the Z1 constraints.

Create the wrapper (right click on block diagram, create HDL wrapper) and make sure that it is set to the top file (Settings-->General: Top module name)
If you get a pin error--will be for the button, open the schematic -> I/O Ports and change btn to pin D19, LVCMOS33. Let it update constraints.


Software Ports
PORTB: seven segment values output
PORTC: bits 7 downto 4 set which of the seven seg output (priority encoder style)
PORTD: bits 3 downto 0 input buttons
Address 40 and 41 allocate to UART - should change