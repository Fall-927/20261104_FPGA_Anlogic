// Two 2x-scaled 5x7 text lines and 17-step meters after image adjustment.
module display_osd(
 input wire [9:0] x,y,
 input wire enable,show,
 input wire [4:0] brightness,contrast,
 input wire [7:0] in_r,in_g,in_b,
 output reg [7:0] red,green,blue
);
 function [34:0] font;
  input [4:0] ch;
  begin case(ch)
   0:font=35'b01110_10001_10011_10101_11001_10001_01110;
   1:font=35'b00100_01100_00100_00100_00100_00100_01110;
   2:font=35'b01110_10001_00001_00010_00100_01000_11111;
   3:font=35'b11110_00001_00001_01110_00001_00001_11110;
   4:font=35'b00010_00110_01010_10010_11111_00010_00010;
   5:font=35'b11111_10000_10000_11110_00001_00001_11110;
   6:font=35'b01110_10000_10000_11110_10001_10001_01110;
   7:font=35'b11111_00001_00010_00100_01000_01000_01000;
   8:font=35'b01110_10001_10001_01110_10001_10001_01110;
   9:font=35'b01110_10001_10001_01111_00001_00001_01110;
   10:font=35'b11110_10001_10001_11110_10001_10001_11110; // B
   11:font=35'b11110_10001_10001_11110_10100_10010_10001; // R
   12:font=35'b01110_00100_00100_00100_00100_00100_01110; // I
   13:font=35'b01110_10001_10000_10000_10000_10001_01110; // C
   14:font=35'b01110_10001_10001_10001_10001_10001_01110; // O
   15:font=35'b10001_11001_11001_10101_10011_10011_10001; // N
   default:font=0;
  endcase end
 endfunction
 reg [4:0] ch,value;
 reg [34:0] glyph;
 reg text_on,bar_on;
 reg [6:0] dx;
 reg [5:0] dy;
 reg [2:0] col,gx,gy;
 always @*begin
  red=in_r;green=in_g;blue=in_b;
  dx=0;dy=0;col=0;gx=0;gy=0;ch=31;value=0;glyph=0;text_on=0;bar_on=0;
  if(enable && show && x>=8 && x<256 && y>=8 && y<88)begin
   red={2'b00,in_r[7:2]};green={2'b00,in_g[7:2]};blue={2'b00,in_b[7:2]};
   dx=x-16;dy=(y<48) ? y-16 : y-56;
   value=(y<48) ? brightness : contrast;
   if(x>=16 && x<88 && ((y>=16 && y<30)||(y>=56 && y<70)))begin
    col=dx/12;gx=(dx%12)/2;gy=dy/2;
    case(col)
     0:ch=(y<48) ? 10 : 13;
     1:ch=(y<48) ? 11 : 14;
     2:ch=(y<48) ? 12 : 15;
     4:ch=(value>=10) ? 1 : 0;
     5:ch=(value>=10) ? value-10 : value;
     default:ch=31;
    endcase
    glyph=font(ch);
    if(gx<5)text_on=glyph[34-gy*5-gx];
   end
   if(x>=104 && x<240 && ((y>=18 && y<28)||(y>=58 && y<68)))begin
    // Each level is an 8-pixel segment, including a mark for level zero.
    bar_on=((x-104)<((value+1)*8)) && x[2:0]!=7;
    red=32;green=40;blue=48;
   end
   if(bar_on)begin red=32;green=208;blue=255;end
   if(text_on)begin red=255;green=255;blue=255;end
   if(x==8 || x==255 || y==8 || y==87)begin red=32;green=144;blue=192;end
  end
 end
endmodule
