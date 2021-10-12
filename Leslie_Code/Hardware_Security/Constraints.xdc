# Clock signal 125 MHz
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { sysclk }];
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 5} [get_ports { sysclk }];

set_property IOSTANDARD LVCMOS33 [get_ports I_RX]
set_property IOSTANDARD LVCMOS33 [get_ports Q_TX]
set_property IOSTANDARD LVCMOS33 [get_ports {Q_7_SEGMENT[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Q_7_SEGMENT[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Q_7_SEGMENT[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Q_7_SEGMENT[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Q_7_SEGMENT[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Q_7_SEGMENT[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Q_7_SEGMENT[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Q_LEDS[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Q_LEDS[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Q_LEDS[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {Q_LEDS[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {I_SWITCH[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {I_SWITCH[0]}]
set_property PACKAGE_PIN W10 [get_ports {Q_7_SEGMENT[6]}]
set_property PACKAGE_PIN Y16 [get_ports {Q_7_SEGMENT[5]}]
set_property PACKAGE_PIN Y19 [get_ports {Q_7_SEGMENT[4]}]
set_property PACKAGE_PIN U18 [get_ports {Q_7_SEGMENT[3]}]
set_property PACKAGE_PIN W8 [get_ports {Q_7_SEGMENT[2]}]
set_property PACKAGE_PIN Y8 [get_ports {Q_7_SEGMENT[1]}]
set_property PACKAGE_PIN W9 [get_ports {Q_7_SEGMENT[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports I_CLK_100]
set_property PACKAGE_PIN M14 [get_ports {Q_LEDS[3]}]
set_property PACKAGE_PIN N16 [get_ports {Q_LEDS[2]}]
set_property PACKAGE_PIN P14 [get_ports {Q_LEDS[1]}]
set_property PACKAGE_PIN R14 [get_ports {Q_LEDS[0]}]
set_property PACKAGE_PIN M19 [get_ports {I_SWITCH[1]}]
set_property PACKAGE_PIN M20 [get_ports {I_SWITCH[0]}]
set_property PACKAGE_PIN J15 [get_ports Q_TX]
set_property PACKAGE_PIN J14 [get_ports I_RX]
