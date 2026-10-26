create_clock -name clk_50m -period 20.000 -waveform {0 10} [get_ports {clk_50m}]
create_generated_clock -name clk_55m -source [get_ports {clk_50m}] -master_clock clk_50m -multiply_by 1.1 [get_nets {u_pll/clk_55m}]
create_generated_clock -name pixel_clk -source [get_ports {clk_50m}] -master_clock clk_50m -multiply_by 1.485 [get_nets {pixel_clk}]
create_generated_clock -name serial_clk -source [get_ports {clk_50m}] -master_clock clk_50m -multiply_by 7.425 [get_nets {serial_clk}]
# No blanket false paths: inspect related-clock transfer setup/hold.
