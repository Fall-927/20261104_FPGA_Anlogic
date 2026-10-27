`timescale 1ns/1ps
// 50 / 5 * 63 = 630 MHz VCO; C0 /25 = 25.2 MHz; C1 /5 = 126 MHz.
module hdmi_pll_480p (
    input wire refclk, input wire reset,
    output wire pixel_clk, output wire serial_clk, output wire locked
);
    wire [2:0] unused_clocks;
    EG_PHY_PLL #(
        .FIN("50.000000"), .FEEDBK_MODE("NOCOMP"),
        .FEEDBK_PATH("VCO_PHASE_0"), .PLLRST_ENA("ENABLE"),
        .DPHASE_SOURCE("DISABLE"), .DYNCFG("DISABLE"),
        .STDBY_ENABLE("DISABLE"), .SYNC_ENABLE("DISABLE"),
        .DERIVE_PLL_CLOCKS("DISABLE"), .GEN_BASIC_CLOCK("DISABLE"),
        .GMC_GAIN(2), .ICP_CURRENT(9), .KVCO(2),
        .LPF_CAPACITOR(1), .LPF_RESISTOR(8),
        .REFCLK_DIV(5), .FBCLK_DIV(63),
        .CLKC0_ENABLE("ENABLE"), .CLKC0_DIV(25),
        .CLKC0_CPHASE(24), .CLKC0_FPHASE(0),
        .CLKC1_ENABLE("ENABLE"), .CLKC1_DIV(5),
        .CLKC1_CPHASE(4), .CLKC1_FPHASE(0)
    ) pll_inst (
        .refclk(refclk), .reset(reset), .extlock(locked), .stdby(1'b0),
        .load_reg(1'b0), .psclk(1'b0), .psdown(1'b0), .psstep(1'b0),
        .psclksel(3'b000), .psdone(), .dclk(1'b0), .dcs(1'b0),
        .dwe(1'b0), .di(8'b0), .daddr(6'b0), .do(), .fbclk(1'b0),
        .clkc({unused_clocks, serial_clk, pixel_clk})
    );
endmodule
