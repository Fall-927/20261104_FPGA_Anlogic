`timescale 1ns/1ps
module transition_tb;
 reg clk=0,reset=1,ready=0,frame_end=0;
 reg [2:0] keys=0;
 wire [3:0] key_row;
 wire [3:0] key_col=key_row==7 ? (4'hf ^ {1'b0,keys}) : 4'hf;
 wire [1:0] image_index;
 wire auto_mode,frame_toggle,busy;
 wire [5:0] level;
 slideshow_controls #(.SCAN_CYCLES(8),.DEBOUNCE_SCANS(2),.AUTO_FRAMES(3)) dut(
 .clk(clk),.reset(reset),.ready(ready),.frame_end(frame_end),
 .key_col(key_col),.key_row(key_row),.image_index(image_index),
 .auto_mode(auto_mode),.frame_toggle(frame_toggle),.fade_level(level),.transition_busy(busy));
 reg [15:0] rgb;
 reg [5:0] gain;
 reg show;
 wire [7:0] r,g,b;
 slideshow_fade fade(.rgb565(rgb),.level(gain),.show(show),.red(r),.green(g),.blue(b));
 task tick; begin clk=0;#5;clk=1;#5;end endtask
 task run; input integer n; integer j;begin for(j=0;j<n;j=j+1)tick;end endtask
 task frame;begin frame_end=1;tick;frame_end=0;run(2);end endtask
 task press; input [2:0] k;begin keys=k;run(150);keys=0;run(150);end endtask
 task check;input ok;begin if(!ok) $fatal(1,"transition check failed: index=%d level=%d busy=%d",image_index,level,busy);end endtask
 integer i,v,k;
 reg [1:0] old_index;
 reg [5:0] old_level;
 reg old_toggle;
 always @(negedge clk)begin
 old_index=image_index;old_level=level;old_toggle=frame_toggle;
 end
 always @(posedge clk)begin
 #1;
 if(!reset)begin
  check(level<=32);
  if(!frame_end)check(image_index==old_index && level==old_level && frame_toggle==old_toggle);
  if(image_index!=old_index)check(frame_end && old_level==0 && level==0);
 end
 end
 initial begin
 run(3);reset=0;run(20);press(2);frame;check(image_index==0 && !busy);
 ready=1;press(1);frame;check(image_index==0 && busy);
 for(i=31;i>=0;i=i-1)begin frame;check(level==i && image_index==0);end
 frame;check(level==0 && image_index==2);
 for(i=1;i<=32;i=i+1)begin frame;check(level==i && image_index==2);end
 check(!busy);
 keys=2;run(150);repeat(70)frame;check(image_index==0 && !busy);
 run(200);frame;check(!busy);keys=0;run(150);
 press(2);frame;repeat(10)frame;press(2);repeat(140)frame;
 check(image_index==2 && !busy);
 press(4);check(auto_mode);repeat(4)frame;check(busy);
 press(4);check(!auto_mode);repeat(70)frame;check(image_index==0 && !busy);
 keys=1;run(5);keys=0;run(150);frame;check(!busy);
 // Exhaustive RGB565 channel values at every supported gain.
 show=1;
 for(k=0;k<=32;k=k+1)begin
  gain=k;
  for(v=0;v<65536;v=v+1)begin
   rgb=v;#1;
   if(r!=((((v>>11)<<3)|((v>>13)&7))*k/32) ||
      g!=(((((v>>5)&63)<<2)|((v>>9)&3))*k/32) ||
      b!=((((v&31)<<3)|((v>>2)&7))*k/32))$fatal(1,"RGB gain mismatch");
  end
 end
 show=0;#1;if({r,g,b}!=0)$fatal(1,"blank output mismatch");
 reset=1;tick;reset=0;tick;check(image_index==0 && level==32 && !busy);
 $display("PASS: transitions, queue, auto, blank boundaries and 2162688 RGB/gain combinations");
 $finish;
 end
endmodule
