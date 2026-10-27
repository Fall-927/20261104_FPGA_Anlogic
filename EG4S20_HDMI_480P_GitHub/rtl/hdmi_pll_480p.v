module hdmi_pll_480p (
    input wire refclk, input wire reset,
    output wire pixel_clk, output wire serial_clk, output wire locked
);
    // Generate pll_480p in TD first: 50 MHz -> 25.2 MHz and 126 MHz, phase 0.
    pll_480p u_core (
        .refclk(refclk), .reset(reset), .extlock(locked),
        .clk0_out(pixel_clk), .clk1_out(serial_clk)
    );
    defparam u_core.pll_inst.DERIVE_PLL_CLOCKS = "DISABLE";
endmodule
