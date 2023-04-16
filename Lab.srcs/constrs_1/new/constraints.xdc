# Keyboard
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN F4} [get_ports{keyboardClock}]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN B2} [get_ports{keyboardData}]

# Switches
set_property IOSTANDARD LVCMOS33 [ get_ports { inp } ]

set_property PACKAGE_PIN R15 [ get_ports { inp[3] } ]
set_property PACKAGE_PIN M13 [ get_ports { inp[2] } ]
set_property PACKAGE_PIN L16 [ get_ports { inp[1] } ]
set_property PACKAGE_PIN J15 [ get_ports { inp[0] } ]

set_property IOSTANDARD LVCMOS33 [ get_ports { mask[7] } ]
set_property IOSTANDARD LVCMOS33 [ get_ports { mask[6] } ]
set_property IOSTANDARD LVCMOS18 [ get_ports { mask[5] } ]
set_property IOSTANDARD LVCMOS18 [ get_ports { mask[4] } ]
set_property IOSTANDARD LVCMOS33 [ get_ports { mask[3] } ]
set_property IOSTANDARD LVCMOS33 [ get_ports { mask[2] } ]
set_property IOSTANDARD LVCMOS33 [ get_ports { mask[1] } ]
set_property IOSTANDARD LVCMOS33 [ get_ports { mask[0] } ]

set_property PACKAGE_PIN T13 [ get_ports { mask[7] } ]
set_property PACKAGE_PIN R16 [ get_ports { mask[6] } ]
set_property PACKAGE_PIN U8 [ get_ports { mask[5] } ]
set_property PACKAGE_PIN T8 [ get_ports { mask[4] } ]
set_property PACKAGE_PIN R13 [ get_ports { mask[3] } ]
set_property PACKAGE_PIN U18 [ get_ports { mask[2] } ]
set_property PACKAGE_PIN T18 [ get_ports { mask[1] } ]
set_property PACKAGE_PIN R17 [ get_ports { mask[0] } ]

set_property IOSTANDARD LVCMOS33 [ get_ports { segmentValues } ]

# Anodes | Display
set_property PACKAGE_PIN H15 [ get_ports { segmentValues[7] } ]
set_property PACKAGE_PIN L18 [ get_ports { segmentValues[6] } ]
set_property PACKAGE_PIN T11 [ get_ports { segmentValues[5] } ]
set_property PACKAGE_PIN P15 [ get_ports { segmentValues[4] } ]
set_property PACKAGE_PIN K13 [ get_ports { segmentValues[3] } ]
set_property PACKAGE_PIN K16 [ get_ports { segmentValues[2] } ]
set_property PACKAGE_PIN R10 [ get_ports { segmentValues[1] } ]
set_property PACKAGE_PIN T10 [ get_ports { segmentValues[0] } ]

set_property IOSTANDARD LVCMOS33 [ get_ports { outMask } ]

# Cathodes | Display
set_property PACKAGE_PIN U13 [ get_ports { outMask[7] } ]
set_property PACKAGE_PIN K2 [ get_ports { outMask[6] } ]
set_property PACKAGE_PIN T14 [ get_ports { outMask[5] } ]
set_property PACKAGE_PIN P14 [ get_ports { outMask[4] } ]
set_property PACKAGE_PIN J14 [ get_ports { outMask[3] } ]
set_property PACKAGE_PIN T9 [ get_ports { outMask[2] } ]
set_property PACKAGE_PIN J18 [ get_ports { outMask[1] } ]
set_property PACKAGE_PIN J17 [ get_ports { outMask[0] } ]

# Buttons
set_property PACKAGE_PIN N17 [ get_ports { button } ]
set_property IOSTANDARD LVCMOS33 [ get_ports { button } ]

set_property PACKAGE_PIN M18 [ get_ports { sortButton } ]
set_property IOSTANDARD LVCMOS33 [ get_ports { sortButton } ]

set_property PACKAGE_PIN P17 [ get_ports { leftButton } ]
set_property IOSTANDARD LVCMOS33 [ get_ports { leftButton } ]

set_property PACKAGE_PIN M17 [ get_ports { rightButton } ]
set_property IOSTANDARD LVCMOS33 [ get_ports { rightButton } ]

set_property PACKAGE_PIN P18 [ get_ports { resetButton } ]
set_property IOSTANDARD LVCMOS33 [ get_ports { resetButton } ]

# Clock
set_property IOSTANDARD LVCMOS33 [ get_ports { clock } ]
set_property PACKAGE_PIN E3 [ get_ports { clock } ]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [ get_ports { clock } ]

