`timescale 1ns/1ps
// Pixel-domain OSD. Two registered stages, including ALL HDMI sidebands.
// No framebuffer writes, additional clocks, CPU, external fonts or new pins.
module slideshow_osd #(
 parameter integer FRAMES_PER_SECOND=60,
 parameter integer SCROLL_FRAME_DIV=1
)(
 input wire clk,reset,enable,
 input wire [9:0] x,y,
 input wire hs,vs,de,
 input wire [23:0] rgb_in,
 input wire [1:0] image_index,
 input wire auto_mode,
 output reg [9:0] out_x,out_y,
 output reg out_hs,out_vs,out_de,out_play,
 output reg [23:0] rgb_out
);
 // 64 cells * 16 pixels, including trailing spaces for a seamless wrap.
 // Update only in vertical blank: text never moves midway through a frame.
 reg [9:0] scroll_offset;
 reg [31:0] scroll_frames,second_frames;
 reg [3:0] ht,hu,mt,mu,st,su;
 reg [1:0] frame_image;
 reg frame_auto;
 reg [23:0] frame_time;
 wire frame_end=(x==0 && y==492);
 always @(posedge clk or posedge reset) begin
  if(reset) begin
   scroll_offset<=0;scroll_frames<=0;second_frames<=0;
   ht<=0;hu<=0;mt<=0;mu<=0;st<=0;su<=0;
   frame_image<=0;frame_auto<=0;frame_time<=0;
  end else begin
   if(frame_end && enable) begin
    if(scroll_frames==SCROLL_FRAME_DIV-1) begin
     scroll_frames<=0;scroll_offset<=scroll_offset+10'd1;
    end else scroll_frames<=scroll_frames+1'b1;
    if(second_frames==FRAMES_PER_SECOND-1) begin
     second_frames<=0;
     if(su!=9) su<=su+1'b1;
     else begin
      su<=0;
      if(st!=5) st<=st+1'b1;
      else begin
       st<=0;
       if(mu!=9) mu<=mu+1'b1;
       else begin
        mu<=0;
        if(mt!=5) mt<=mt+1'b1;
        else begin
         mt<=0;
         if(hu!=9) hu<=hu+1'b1;
         else begin hu<=0;ht<=(ht==9) ? 4'd0:ht+1'b1;end
        end
       end
      end
     end
    end else second_frames<=second_frames+1'b1;
   end
   // Controls commit at y=492; snapshot after that, before the next image.
   if(x==0 && y==524) begin
    frame_image<=image_index;frame_auto<=auto_mode;
    frame_time<={ht,hu,mt,mu,st,su};
   end
  end
 end

 // Original 5x7 ASCII bitmap font, stored as seven rows, MSB = left pixel.
 // Uppercase, digits and punctuation needed by both strings are included.
 function [34:0] glyph;
  input [7:0] c;
  begin case(c)
   "A":glyph={5'b01110,5'b10001,5'b10001,5'b11111,5'b10001,5'b10001,5'b10001};
   "B":glyph={5'b11110,5'b10001,5'b10001,5'b11110,5'b10001,5'b10001,5'b11110};
   "C":glyph={5'b01111,5'b10000,5'b10000,5'b10000,5'b10000,5'b10000,5'b01111};
   "D":glyph={5'b11110,5'b10001,5'b10001,5'b10001,5'b10001,5'b10001,5'b11110};
   "E":glyph={5'b11111,5'b10000,5'b10000,5'b11110,5'b10000,5'b10000,5'b11111};
   "F":glyph={5'b11111,5'b10000,5'b10000,5'b11110,5'b10000,5'b10000,5'b10000};
   "G":glyph={5'b01111,5'b10000,5'b10000,5'b10111,5'b10001,5'b10001,5'b01111};
   "H":glyph={5'b10001,5'b10001,5'b10001,5'b11111,5'b10001,5'b10001,5'b10001};
   "I":glyph={5'b11111,5'b00100,5'b00100,5'b00100,5'b00100,5'b00100,5'b11111};
   "J":glyph={5'b00111,5'b00010,5'b00010,5'b00010,5'b10010,5'b10010,5'b01100};
   "K":glyph={5'b10001,5'b10010,5'b10100,5'b11000,5'b10100,5'b10010,5'b10001};
   "L":glyph={5'b10000,5'b10000,5'b10000,5'b10000,5'b10000,5'b10000,5'b11111};
   "M":glyph={5'b10001,5'b11011,5'b10101,5'b10101,5'b10001,5'b10001,5'b10001};
   "N":glyph={5'b10001,5'b11001,5'b10101,5'b10011,5'b10001,5'b10001,5'b10001};
   "O":glyph={5'b01110,5'b10001,5'b10001,5'b10001,5'b10001,5'b10001,5'b01110};
   "P":glyph={5'b11110,5'b10001,5'b10001,5'b11110,5'b10000,5'b10000,5'b10000};
   "Q":glyph={5'b01110,5'b10001,5'b10001,5'b10001,5'b10101,5'b10010,5'b01101};
   "R":glyph={5'b11110,5'b10001,5'b10001,5'b11110,5'b10100,5'b10010,5'b10001};
   "S":glyph={5'b01111,5'b10000,5'b10000,5'b01110,5'b00001,5'b00001,5'b11110};
   "T":glyph={5'b11111,5'b00100,5'b00100,5'b00100,5'b00100,5'b00100,5'b00100};
   "U":glyph={5'b10001,5'b10001,5'b10001,5'b10001,5'b10001,5'b10001,5'b01110};
   "V":glyph={5'b10001,5'b10001,5'b10001,5'b10001,5'b10001,5'b01010,5'b00100};
   "W":glyph={5'b10001,5'b10001,5'b10001,5'b10101,5'b10101,5'b10101,5'b01010};
   "X":glyph={5'b10001,5'b10001,5'b01010,5'b00100,5'b01010,5'b10001,5'b10001};
   "Y":glyph={5'b10001,5'b10001,5'b01010,5'b00100,5'b00100,5'b00100,5'b00100};
   "Z":glyph={5'b11111,5'b00001,5'b00010,5'b00100,5'b01000,5'b10000,5'b11111};
   "0":glyph={5'b01110,5'b10001,5'b10011,5'b10101,5'b11001,5'b10001,5'b01110};
   "1":glyph={5'b00100,5'b01100,5'b00100,5'b00100,5'b00100,5'b00100,5'b01110};
   "2":glyph={5'b01110,5'b10001,5'b00001,5'b00010,5'b00100,5'b01000,5'b11111};
   "3":glyph={5'b11110,5'b00001,5'b00001,5'b01110,5'b00001,5'b00001,5'b11110};
   "4":glyph={5'b00010,5'b00110,5'b01010,5'b10010,5'b11111,5'b00010,5'b00010};
   "5":glyph={5'b11111,5'b10000,5'b10000,5'b11110,5'b00001,5'b00001,5'b11110};
   "6":glyph={5'b01110,5'b10000,5'b10000,5'b11110,5'b10001,5'b10001,5'b01110};
   "7":glyph={5'b11111,5'b00001,5'b00010,5'b00100,5'b01000,5'b01000,5'b01000};
   "8":glyph={5'b01110,5'b10001,5'b10001,5'b01110,5'b10001,5'b10001,5'b01110};
   "9":glyph={5'b01110,5'b10001,5'b10001,5'b01111,5'b00001,5'b00001,5'b01110};
   ":":glyph={5'b00000,5'b00100,5'b00100,5'b00000,5'b00100,5'b00100,5'b00000};
   "/":glyph={5'b00001,5'b00001,5'b00010,5'b00100,5'b01000,5'b10000,5'b10000};
   "-":glyph={5'b00000,5'b00000,5'b00000,5'b11111,5'b00000,5'b00000,5'b00000};
   default:glyph=35'd0;
  endcase end
 endfunction
 function font_pixel;
  input [7:0] c;
  input [2:0] row,col;
  reg [34:0] bits;
  begin
   bits=glyph(c);
   font_pixel=0;
   if(row<7 && col<5) font_pixel=bits[34-row*5-{29'd0,col}];
  end
 endfunction
 function [7:0] status_char;
  input [5:0] n;
  begin case(n)
   0:status_char="A";1:status_char="N";2:status_char="L";
   3:status_char="O";4:status_char="G";5:status_char="I";6:status_char="C";
   8:status_char="I";9:status_char="M";10:status_char="G";
   12:status_char=8'd49+{6'd0,frame_image};13:status_char="/";14:status_char="3";
   16:status_char=frame_auto ? "A":"M";
   17:status_char=frame_auto ? "U":"A";
   18:status_char=frame_auto ? "T":"N";
   19:status_char=frame_auto ? "O":"U";
   20:status_char=frame_auto ? " ":"A";
   21:status_char=frame_auto ? " ":"L";
   23:status_char="U";24:status_char="P";
   26:status_char=8'd48+{4'd0,frame_time[23:20]};
   27:status_char=8'd48+{4'd0,frame_time[19:16]};
   28:status_char=":";
   29:status_char=8'd48+{4'd0,frame_time[15:12]};
   30:status_char=8'd48+{4'd0,frame_time[11:8]};
   31:status_char=":";
   32:status_char=8'd48+{4'd0,frame_time[7:4]};
   33:status_char=8'd48+{4'd0,frame_time[3:0]};
   default:status_char=" ";
  endcase end
 endfunction
 // Edit this 64-character cyclic message to customize the slogan.
 localparam [511:0] MESSAGE={
  "WELCOME TO ANLOGIC FPGA  ",
  "HDMI MULTIMEDIA SHOW  ",
  "LAYER OSD DEMO   "};
 function [7:0] message_char;
  input [5:0] n;
  begin message_char=MESSAGE[511-n*8 -: 8];end
 endfunction

 wire [9:0] top_x=x-10'd32,top_y=y-10'd24;
 wire [9:0] ticker_x=x-10'd16+scroll_offset,ticker_y=y-10'd440;
 wire [9:0] shadow_x=ticker_x-10'd2,shadow_y=ticker_y-10'd2;
 wire top_band=(x>=16 && x<624 && y>=12 && y<52);
 wire bottom_band=(x>=16 && x<624 && y>=424 && y<472);
 wire top_text=top_band && x>=32 && y>=24 && y<40 &&
               font_pixel(status_char(top_x[9:4]),top_y[3:1],top_x[3:1]);
 wire ticker_text=bottom_band && y>=440 && y<456 &&
                  font_pixel(message_char(ticker_x[9:4]),ticker_y[3:1],ticker_x[3:1]);
 wire ticker_shadow=bottom_band && y>=442 && y<458 &&
                    font_pixel(message_char(shadow_x[9:4]),shadow_y[3:1],shadow_x[3:1]);
 wire accent=(top_band && x<20) || (bottom_band && y<426);

 reg [9:0] x1,y1;
 reg hs1,vs1,de1,play1;
 reg [23:0] rgb1;
 reg band1,top_text1,ticker_text1,shadow1,accent1;
 function [7:0] half_mix;
  input [7:0] a,b;
  reg [8:0] sum;
  begin sum={1'b0,a}+{1'b0,b};half_mix=sum[8:1];end
 endfunction
 // Layer order: image -> 50% navy panel -> shadow -> 50% cyan accent
 // -> opaque status text / 75% yellow ticker. Blend each channel separately.
 reg [23:0] composed;
 reg [7:0] r,g,b;
 always @* begin
  r=rgb1[23:16];g=rgb1[15:8];b=rgb1[7:0];
  if(band1) begin r=half_mix(r,8'd8);g=half_mix(g,8'd16);b=half_mix(b,8'd32);end
  if(shadow1) begin r=r>>1;g=g>>1;b=b>>1;end
  if(accent1) begin r=half_mix(r,8'd32);g=half_mix(g,8'd224);b=half_mix(b,8'd255);end
  if(top_text1) begin r=255;g=255;b=255;end
  if(ticker_text1) begin
   r=half_mix(half_mix(r,8'd255),8'd255);
   g=half_mix(half_mix(g,8'd224),8'd224);
   b=half_mix(half_mix(b,8'd64),8'd64);
  end
  composed=de1 ? {r,g,b}:24'd0;
 end
 always @(posedge clk or posedge reset) begin
  if(reset) begin
   x1<=0;y1<=0;hs1<=1;vs1<=1;de1<=0;play1<=0;rgb1<=0;
   band1<=0;top_text1<=0;ticker_text1<=0;shadow1<=0;accent1<=0;
   out_x<=0;out_y<=0;out_hs<=1;out_vs<=1;out_de<=0;out_play<=0;rgb_out<=0;
  end else begin
   x1<=x;y1<=y;hs1<=hs;vs1<=vs;de1<=de;play1<=enable;rgb1<=rgb_in;
   band1<=enable && de && (top_band || bottom_band);
   top_text1<=enable && de && top_text;
   ticker_text1<=enable && de && ticker_text;
   shadow1<=enable && de && ticker_shadow;accent1<=enable && de && accent;
   out_x<=x1;out_y<=y1;out_hs<=hs1;out_vs<=vs1;out_de<=de1;out_play<=play1;
   rgb_out<=composed;
  end
 end
endmodule
