// 0..32 gain; 32 is exact unity. No latency: video/audio timing is unchanged.
module slideshow_fade(
 input wire [15:0] rgb565,
 input wire [5:0] level,
 input wire show,
 output wire [7:0] red,green,blue
);
 wire [7:0] r={rgb565[15:11],rgb565[15:13]};
 wire [7:0] g={rgb565[10:5],rgb565[10:9]};
 wire [7:0] b={rgb565[4:0],rgb565[4:2]};
 wire [13:0] rs=r*level,gs=g*level,bs=b*level;
 assign red=show ? rs[12:5] : 8'd0;
 assign green=show ? gs[12:5] : 8'd0;
 assign blue=show ? bs[12:5] : 8'd0;
endmodule
