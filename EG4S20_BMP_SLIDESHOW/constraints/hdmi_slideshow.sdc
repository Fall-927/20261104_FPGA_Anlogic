create_clock -name clk_50m -period 20.000 [get_ports {clk_50m}]
create_generated_clock -name pixel_clk -source [get_ports {clk_50m}] -multiply_by 0.504 [get_nets {pixel_clk}]
create_generated_clock -name serial_clk -source [get_ports {clk_50m}] -multiply_by 2.52 [get_nets {serial_clk}]
create_generated_clock -name mem_clk -source [get_ports {clk_50m}] -multiply_by 2 [get_nets {mem_clk}]
create_generated_clock -name mem_clk_shift -source [get_ports {clk_50m}] -multiply_by 2 -phase 270 [get_nets {mem_clk_shift}]
# Treat memory as a separate asynchronous group: all transfers use Gray-pointer
# dual-clock FIFOs or two-flop status synchronizers. Keep pixel/serial related.
set_clock_groups -asynchronous -group {mem_clk mem_clk_shift} -group {clk_50m pixel_clk serial_clk}
# clk_50m -> video crosses only the synchronized error/status bus.
set_false_path -from [get_clocks {clk_50m}] -to [get_clocks {pixel_clk serial_clk}]
set_false_path -from [get_clocks {pixel_clk serial_clk}] -to [get_clocks {clk_50m}]
# FIFO Gray-pointer and status crossings must be reviewed in implementation.
# SPI interface is mode 0; external input/output timing needs card/PCB qualification.
