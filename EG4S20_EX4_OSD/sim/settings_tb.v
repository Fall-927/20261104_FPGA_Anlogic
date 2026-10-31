`timescale 1ns/1ps
module settings_tb;
 reg clk=0,reset=1,frame_end=0;
 reg [15:0] pressed=0;
 wire [4:0] brightness,contrast;
 wire enabled;
 display_settings settings(clk,reset,frame_end,pressed,brightness,contrast,enabled);
 reg [15:0] rgb;
 reg [4:0] bv,cv;
 reg show;
 wire [7:0] r,g,b;
 display_adjust adjust(rgb,bv,cv,show,r,g,b);
 reg [9:0] x,y;
 wire [7:0] ro,go,bo;
 display_osd osd(x,y,enabled,show,brightness,contrast,r,g,b,ro,go,bo);
 task tick;begin clk=0;#5;clk=1;#5;end endtask
 task key;input integer n;begin pressed=16'b1<<n;tick;pressed=0;tick;end endtask
 task frame;begin frame_end=1;tick;frame_end=0;tick;end endtask
 task check;input ok;begin if(!ok)$fatal(1,"settings assertion failed");end endtask
 function integer ref_value;
 input integer v,bb,cc,ff;
 integer t;
 begin t=(((v-128)*cc)>>>3)+128+(bb-8)*16;
 if(t<0)t=0;if(t>255)t=255;ref_value=t*ff/32;end
 endfunction
 integer i,j,k,v;
 initial begin
 tick;reset=0;tick;check(brightness==8 && contrast==8 && enabled);
 key(9);check(brightness==8);frame;check(brightness==9);
 repeat(30)key(9);frame;check(brightness==16);
 repeat(40)key(8);frame;check(brightness==0);
 repeat(30)key(5);frame;check(contrast==16);
 repeat(40)key(4);frame;check(contrast==0);
 key(0);frame;check(brightness==8 && contrast==8);
 key(1);check(enabled);frame;check(!enabled);key(1);frame;check(enabled);
 show=1;
 for(i=0;i<=16;i=i+1)for(j=0;j<=16;j=j+1)for(v=0;v<256;v=v+1)begin
  bv=i;cv=j;rgb={v[7:3],v[7:2],v[7:3]};#1;
  check(r==ref_value({v[7:3],v[7:5]},i,j,32));
  check(g==ref_value({v[7:2],v[7:6]},i,j,32));
  check(b==ref_value({v[7:3],v[7:5]},i,j,32));
 end
 x=17;y=17;#1;check({ro,go,bo}!=0);
 x=300;y=100;#1;check({ro,go,bo}=={r,g,b});
 show=0;x=17;y=17;#1;check({ro,go,bo}==0);
 $display("PASS settings: blank commit, limits, reset, OSD gating, 73984 RGB setting combinations");$finish;
 end
endmodule
