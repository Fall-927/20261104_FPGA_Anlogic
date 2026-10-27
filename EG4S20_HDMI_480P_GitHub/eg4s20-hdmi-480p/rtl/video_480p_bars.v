`timescale 1ns/1ps
module video_480p_bars (
    input wire clk, input wire reset,
    output wire hsync, output wire vsync, output wire de,
    output reg [7:0] red, output reg [7:0] green, output reg [7:0] blue
);
    // 25.2 MHz / (800 * 525) = 60 Hz. Negative HS and VS.
    // H: active/front/sync/back = 640/16/96/48.
    // V: active/front/sync/back = 480/10/2/33.
    reg [9:0] x;
    reg [9:0] y;
    always @(posedge clk or posedge reset) begin
        if (reset) begin x <= 0; y <= 0; end
        else if (x == 10'd799) begin
            x <= 0;
            if (y == 10'd524) y <= 0;
            else y <= y + 1'b1;
        end else x <= x + 1'b1;
    end
    assign hsync = !(x >= 10'd656 && x < 10'd752);
    assign vsync = !(y >= 10'd490 && y < 10'd492);
    assign de = !reset && (x < 10'd640 && y < 10'd480);
    always @* begin
        {red, green, blue} = 24'h000000;
        if (de) begin
            if      (x < 10'd80)  {red, green, blue} = 24'hffffff;
            else if (x < 10'd160) {red, green, blue} = 24'hffff00;
            else if (x < 10'd240) {red, green, blue} = 24'h00ffff;
            else if (x < 10'd320) {red, green, blue} = 24'h00ff00;
            else if (x < 10'd400) {red, green, blue} = 24'hff00ff;
            else if (x < 10'd480) {red, green, blue} = 24'hff0000;
            else if (x < 10'd560) {red, green, blue} = 24'h0000ff;
            else                 {red, green, blue} = 24'h000000;
        end
    end
endmodule
