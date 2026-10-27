create_clock -name clk_50m -period 20.000 -waveform {0 10} [get_ports {clk_50m}]
create_generated_clock -name pixel_clk -source [get_ports {clk_50m}] -master_clock clk_50m -multiply_by 0.504 [get_nets {pixel_clk}]
create_generated_clock -name serial_clk -source [get_ports {clk_50m}] -master_clock clk_50m -multiply_by 2.52 [get_nets {serial_clk}]
# Related clocks: no asynchronous clock groups or blanket false paths.
