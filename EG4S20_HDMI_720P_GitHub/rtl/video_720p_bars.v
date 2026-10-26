`timescale 1ns/1ps
module video_720p_bars (
    input wire clk, input wire reset,
    output wire hsync, output wire vsync, output wire de,
    output reg [7:0] red, output reg [7:0] green, output reg [7:0] blue
);
    // CEA 720p60: 74.25 MHz / (1650 * 750) = 60 Hz.
    // H: active 1280, front 110, sync 40, back 220, positive sync.
    // V: active 720, front 5, sync 5, back 20, positive sync.
    reg [10:0] x;
    reg [9:0] y;
    always @(posedge clk or posedge reset) begin
        if (reset) begin x <= 0; y <= 0; end
        else if (x == 1649) begin
            x <= 0;
            if (y == 749) y <= 0;
            else y <= y + 1'b1;
        end else x <= x + 1'b1;
    end
    assign hsync = (x >= 1390 && x < 1430);
    assign vsync = (y >= 725 && y < 730);
    assign de = !reset && (x < 1280 && y < 720);
    always @* begin
        {red, green, blue} = 24'h000000;
        if (de) begin
            if      (x < 160)  {red, green, blue} = 24'hffffff;
            else if (x < 320)  {red, green, blue} = 24'hffff00;
            else if (x < 480)  {red, green, blue} = 24'h00ffff;
            else if (x < 640)  {red, green, blue} = 24'h00ff00;
            else if (x < 800)  {red, green, blue} = 24'hff00ff;
            else if (x < 960)  {red, green, blue} = 24'hff0000;
            else if (x < 1120) {red, green, blue} = 24'h0000ff;
            else              {red, green, blue} = 24'h000000;
        end
    end
endmodule
