## Configuring LEDs
#set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports { LD0 }];
#set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports { LD1 }];
#set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports { LD2 }];
#set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports { LD3 }];
# Clock signal 125 MHz
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { sysclk }];
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 5} [get_ports { sysclk }];

#output pin
set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports { clk_out }];

#reset btn
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports { reset_0 }];