
# seven seg pins
set_property -dict {PACKAGE_PIN W10 IOSTANDARD LVCMOS33} [get_ports { LED[6] }]; --a
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports { LED[5] }]; --b
set_property -dict {PACKAGE_PIN Y19 IOSTANDARD LVCMOS33} [get_ports { LED[4] }]; --c
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports { LED[3] }]; --d
set_property -dict {PACKAGE_PIN W8  IOSTANDARD LVCMOS33} [get_ports { LED[2] }]; --e
set_property -dict {PACKAGE_PIN Y8  IOSTANDARD LVCMOS33} [get_ports { LED[1] }]; --f
set_property -dict {PACKAGE_PIN W9  IOSTANDARD LVCMOS33} [get_ports { LED[0] }]; --g


# Push Buttons
set_property -dict {PACKAGE_PIN D19 IOSTANDARD LVCMOS33} [get_ports { BTN[0] }];
set_property -dict {PACKAGE_PIN D20 IOSTANDARD LVCMOS33} [get_ports { BTN[1] }];
set_property -dict {PACKAGE_PIN L20 IOSTANDARD LVCMOS33} [get_ports { BTN[2] }];
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVCMOS33} [get_ports { BTN[3] }];