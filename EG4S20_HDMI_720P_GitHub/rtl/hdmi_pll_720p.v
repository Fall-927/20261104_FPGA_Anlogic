`timescale 1ns/1ps
// al_ip/SWLED.v and al_ip/pll.v are the two generated PLLs.
module hdmi_pll_720p (
    input wire refclk,
    input wire reset,
    output wire pixel_clk,
    output wire serial_clk,
    output wire locked
);
    wire clk_55m;
    wire lock_stage1, lock_stage2;
    SWLED u_stage1 (
        .refclk(refclk), .reset(reset),
        .clk0_out(clk_55m), .extlock(lock_stage1)
    );

    // Asynchronous assertion, synchronous release on the 55 MHz clock.
    wire reset_stage2_async = reset | ~lock_stage1;
    reg [2:0] reset_stage2_pipe;
    always @(posedge clk_55m or posedge reset_stage2_async)
        if (reset_stage2_async) reset_stage2_pipe <= 3'b111;
        else reset_stage2_pipe <= {reset_stage2_pipe[1:0], 1'b0};

    pll u_stage2 (
        .refclk(clk_55m), .reset(reset_stage2_pipe[2]),
        .clk0_out(pixel_clk), .clk1_out(serial_clk), .extlock(lock_stage2)
    );
    // TD 4.6 cascade workaround: related clocks are explicitly defined in SDC.
    defparam u_stage1.pll_inst.DERIVE_PLL_CLOCKS = "DISABLE";
    defparam u_stage2.pll_inst.DERIVE_PLL_CLOCKS = "DISABLE";
    assign locked = lock_stage1 & lock_stage2 & ~reset;
endmodule
