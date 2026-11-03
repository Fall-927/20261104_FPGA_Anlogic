create_clock -name clk_50m -period 20.000 [get_ports {clk_50m}]
create_generated_clock -name pixel_clk -source [get_ports {clk_50m}] -multiply_by 0.504 [get_nets {player/pixel_clk}]
create_generated_clock -name serial_clk -source [get_ports {clk_50m}] -multiply_by 2.52 [get_nets {player/serial_clk}]
create_generated_clock -name mem_clk -source [get_ports {clk_50m}] -multiply_by 2 [get_nets {player/mem_clk}]
create_generated_clock -name mem_clk_shift -source [get_ports {clk_50m}] -multiply_by 2 -phase 270 [get_nets {player/mem_clk_shift}]
set_clock_groups -asynchronous -group {mem_clk mem_clk_shift} -group {clk_50m pixel_clk serial_clk}
set_false_path -from [get_clocks {clk_50m}] -to [get_clocks {pixel_clk serial_clk}]
set_false_path -from [get_clocks {pixel_clk serial_clk}] -to [get_clocks {clk_50m}]
