# Single Color Leds
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports { LD[0] }];
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports { LD[1] }];
set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports { LD[2] }];
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports { LD[3] }];
# Push Buttons
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports { BTN[0] }];
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports { BTN[1] }];
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports { BTN[2] }];
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33} [get_ports { BTN[3] }];