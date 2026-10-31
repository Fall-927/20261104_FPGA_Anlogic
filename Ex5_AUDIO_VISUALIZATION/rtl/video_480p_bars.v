`timescale 1ns/1ps
module video_480p_bars (
    input wire clk, input wire reset,
    output wire hsync, output wire vsync, output wire de,
    output wire [9:0] pixel_x,output wire [9:0] pixel_y,
    output reg [7:0] red, output reg [7:0] green, output reg [7:0] blue
);
    // 25.2 MHz / (800 * 525) = 60 Hz; negative H/V sync.
    // H: 640 active, 16 front, 96 sync, 48 back.
    // V: 480 active, 10 front, 2 sync, 33 back.
    reg [9:0] x;
    reg [9:0] y;
    assign pixel_x=x;
    assign pixel_y=y;
    always @(posedge clk or posedge reset) begin
        if (reset) begin x <= 0; y <= 0; end
        else if (x == 799) begin
            x <= 0;
            if (y == 524) y <= 0;
            else y <= y + 1'b1;
        end else x <= x + 1'b1;
    end
    assign hsync = !(x >= 656 && x < 752);
    assign vsync = !(y >= 490 && y < 492);
    assign de = !reset && (x < 640 && y < 480);
    always @* begin
        {red, green, blue} = 24'h000000;
        if (de) begin
            if      (x < 80)  {red, green, blue} = 24'hffffff;
            else if (x < 160) {red, green, blue} = 24'hffff00;
            else if (x < 240) {red, green, blue} = 24'h00ffff;
            else if (x < 320) {red, green, blue} = 24'h00ff00;
            else if (x < 400) {red, green, blue} = 24'hff00ff;
            else if (x < 480) {red, green, blue} = 24'hff0000;
            else if (x < 560) {red, green, blue} = 24'h0000ff;
            else             {red, green, blue} = 24'h000000;
        end
    end
endmodule
