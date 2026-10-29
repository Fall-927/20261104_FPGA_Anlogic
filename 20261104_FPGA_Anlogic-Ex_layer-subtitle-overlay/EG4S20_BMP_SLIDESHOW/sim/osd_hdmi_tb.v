`timescale 1ns/1ps
// Compare the actual OSD->HDMI chain against an independently delayed HDMI
// reference. This catches a forgotten coordinate/sync/play pipeline connection.
module osd_hdmi_tb;
 reg clk=0,reset=1;
 reg [9:0] x=0,y=0;
 reg hs=1,vs=1,de=0,play=0;
 reg [23:0] rgb=0;
 wire [9:0] ox,oy,sb,sg,sr,rb,rg,rr;
 wire oh,ov,od,op,overflow,ref_overflow;
 wire [23:0] color;
 reg [9:0] xd0=0,yd0=0,xd1=0,yd1=0;
 reg hd0=1,vd0=1,dd0=0,pd0=0,hd1=1,vd1=1,dd1=0,pd1=0;
 slideshow_osd osd(.clk(clk),.reset(reset),.enable(play),.x(x),.y(y),
 .hs(hs),.vs(vs),.de(de),.rgb_in(rgb),.image_index(2'd1),.auto_mode(1'b1),
 .out_x(ox),.out_y(oy),.out_hs(oh),.out_vs(ov),.out_de(od),.out_play(op),.rgb_out(color));
 hdmi_audio_tx tx(.clk(clk),.reset(reset),.play(op),.x(ox),.y(oy),.hs(oh),.vs(ov),.de(od),
 .red(color[23:16]),.green(color[15:8]),.blue(color[7:0]),
 .symbol_b(sb),.symbol_g(sg),.symbol_r(sr),.audio_overflow(overflow));
 hdmi_audio_tx reference_tx(.clk(clk),.reset(reset),.play(pd1),.x(xd1),.y(yd1),
 .hs(hd1),.vs(vd1),.de(dd1),
 .red(color[23:16]),.green(color[15:8]),.blue(color[7:0]),
 .symbol_b(rb),.symbol_g(rg),.symbol_r(rr),.audio_overflow(ref_overflow));
 always @(posedge clk) begin
  if(reset) begin
   xd0<=0;yd0<=0;hd0<=1;vd0<=1;dd0<=0;pd0<=0;
   xd1<=0;yd1<=0;hd1<=1;vd1<=1;dd1<=0;pd1<=0;
  end else begin
   xd0<=x;yd0<=y;hd0<=hs;vd0<=vs;dd0<=de;pd0<=play;
   xd1<=xd0;yd1<=yd0;hd1<=hd0;vd1<=vd0;dd1<=dd0;pd1<=pd0;
  end
 end
 integer t;
 task tick;begin #5;clk=1;#5;clk=0;end endtask
 initial begin
  tick;reset=0;
  for(t=0;t<4*420000+4;t=t+1) begin
   x=t%800;y=(t/800)%525;de=x<640 && y<480;
   hs=!(x>=656 && x<752);vs=!(y>=490 && y<492);
   play=t>=420000 && t<3*420000;
   rgb={x[7:0],y[7:0],8'h55};tick;
   if({ox,oy,oh,ov,od,op}!=={xd1,yd1,hd1,vd1,dd1,pd1}) $fatal(1,"HDMI sidebands misaligned");
   if({sb,sg,sr}!=={rb,rg,rr}) $fatal(1,"HDMI video/audio symbols changed");
   if(overflow || ref_overflow) $fatal(1,"audio FIFO overflow");
  end
  $display("PASS OSD->HDMI integration: %0d cycles, video/control/audio symbols, enable/disable and no FIFO overflow",t);
  $finish;
 end
endmodule
