/************************************************************\
 **   Copyright (c) 2012-2024 Anlogic
 **  All Right Reserved.
\************************************************************/
`timescale 1 ns / 100 fs
module PLL(refclk,
		reset,
		extlock,
		clk0_out,
		clk1_out);
	input refclk;
	input reset;
	output extlock;
	output clk0_out;
	output clk1_out;
	EG_PHY_PLL #(.DPHASE_SOURCE("DISABLE"),
		.DYNCFG("DISABLE"),
		.FIN("50.000000"),
		.FEEDBK_MODE("NOCOMP"),
		.FEEDBK_PATH("VCO_PHASE_0"),
		.STDBY_ENABLE("DISABLE"),
		.PLLRST_ENA("ENABLE"),
		.SYNC_ENABLE("DISABLE"),
		.DERIVE_PLL_CLOCKS("DISABLE"),
		.GEN_BASIC_CLOCK("DISABLE"),
		.GMC_GAIN(0),
		.ICP_CURRENT(9),
		.KVCO(2),
		.LPF_CAPACITOR(2),
		.LPF_RESISTOR(8),
		.REFCLK_DIV(5),
		.FBCLK_DIV(63),
		.CLKC0_ENABLE("ENABLE"),
		.CLKC0_DIV(25),
		.CLKC0_CPHASE(24),
		.CLKC0_FPHASE(0),
		.CLKC1_ENABLE("ENABLE"),
		.CLKC1_DIV(5),
		.CLKC1_CPHASE(4),
		.CLKC1_FPHASE(0)	)
	pll_inst (.refclk(refclk),
		.reset(reset),
		.stdby(1'b0),
		.extlock(extlock),
		.load_reg(1'b0),
		.psclk(1'b0),
		.psdown(1'b0),
		.psstep(1'b0),
		.psclksel(3'b000),
		.psdone(open),
		.dclk(1'b0),
		.dcs(1'b0),
		.dwe(1'b0),
		.di(8'b00000000),
		.daddr(6'b000000),
		.do({open, open, open, open, open, open, open, open}),
		.fbclk(1'b0),
		.clkc({open, open, open, clk1_out, clk0_out}));
endmodule
