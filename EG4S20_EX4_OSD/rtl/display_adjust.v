// Contrast about midpoint 128, then signed brightness offset, then saturate.
// Neutral settings (8,8) preserve every input bit. No pixel latency.
module display_adjust(
 input wire [15:0] rgb565,
 input wire [4:0] brightness,contrast,
 input wire show,
 output wire [7:0] red,green,blue
);
 function [7:0] adjust;
  input [7:0] value;
  input [4:0] b,c;
  reg signed [9:0] centered,offset;
  reg signed [15:0] product,result;
  begin
   centered=$signed({1'b0,value})-10'sd128;
   offset=($signed({1'b0,b})-10'sd8)*10'sd16;
   product=centered*$signed({1'b0,c});
   result=(product>>>3)+16'sd128+offset;
   if(result<0)adjust=0;
   else if(result>255)adjust=255;
   else adjust=result[7:0];
  end
 endfunction
 wire [7:0] r=adjust({rgb565[15:11],rgb565[15:13]},brightness,contrast);
 wire [7:0] g=adjust({rgb565[10:5],rgb565[10:9]},brightness,contrast);
 wire [7:0] b=adjust({rgb565[4:0],rgb565[4:2]},brightness,contrast);
 assign red=show ? r : 8'd0;
 assign green=show ? g : 8'd0;
 assign blue=show ? b : 8'd0;
endmodule
