`timescale 1ns/1ps
// 640x480 at 60 Hz; LVDS33 automatically drives the paired N pins.
module hdmi_color_top (
    input wire clk_50m,
    input wire rst_n,
    output wire led,
    output wire [2:0] hdmi_data_p,
    output wire hdmi_clk_p
);
    wire pixel_clk, serial_clk, locked;
    hdmi_pll_480p u_pll (
        .refclk(clk_50m), .reset(~rst_n),
        .pixel_clk(pixel_clk), .serial_clk(serial_clk), .locked(locked)
    );
    wire reset_async = ~rst_n | ~locked;
    reg [2:0] pixel_reset_pipe;
    reg [2:0] serial_reset_pipe;
    always @(posedge pixel_clk or posedge reset_async)
        if (reset_async) pixel_reset_pipe <= 3'b111;
        else pixel_reset_pipe <= {pixel_reset_pipe[1:0], 1'b0};
    always @(posedge serial_clk or posedge reset_async)
        if (reset_async) serial_reset_pipe <= 3'b111;
        else serial_reset_pipe <= {serial_reset_pipe[1:0], 1'b0};
    wire pixel_reset = pixel_reset_pipe[2];
    wire serial_reset = serial_reset_pipe[2];
    wire hs, vs, de;
    wire [7:0] red, green, blue;
    video_480p_bars u_video (
        .clk(pixel_clk), .reset(pixel_reset), .hsync(hs), .vsync(vs),
        .de(de), .red(red), .green(green), .blue(blue)
    );
    wire [9:0] symbol_b, symbol_g, symbol_r;
    tmds_encoder u_blue (.clk(pixel_clk), .reset(pixel_reset), .de(de),
        .c0(hs), .c1(vs), .data(blue), .symbol(symbol_b));
    tmds_encoder u_green (.clk(pixel_clk), .reset(pixel_reset), .de(de),
        .c0(1'b0), .c1(1'b0), .data(green), .symbol(symbol_g));
    tmds_encoder u_red (.clk(pixel_clk), .reset(pixel_reset), .de(de),
        .c0(1'b0), .c1(1'b0), .data(red), .symbol(symbol_r));

    reg pixel_toggle;
    always @(posedge pixel_clk or posedge pixel_reset)
        if (pixel_reset) pixel_toggle <= 1'b0;
        else pixel_toggle <= ~pixel_toggle;

    wire [2:0] serial_data;
    wire serial_clock;
    tmds_serializer_eg4 u_tx (
        .clk_5x(serial_clk), .reset(serial_reset), .pixel_toggle(pixel_toggle),
        .symbol_b(symbol_b), .symbol_g(symbol_g), .symbol_r(symbol_r),
        .serial_data(serial_data), .serial_clock(serial_clock)
    );
    assign hdmi_data_p = serial_data;
    assign hdmi_clk_p = serial_clock;
    assign led = locked;
endmodule
