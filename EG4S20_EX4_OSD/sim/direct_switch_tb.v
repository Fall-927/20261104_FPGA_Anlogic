`timescale 1ns/1ps
module direct_switch_tb;
 reg clk=0,reset=1,ready=0,frame_end=0;
 reg [2:0] keys=0;
 wire [3:0] row;
 wire [3:0] cols=row==7 ? (4'hf ^ {1'b0,keys}) : 4'hf;
 wire [1:0] image;
 wire auto_mode,toggle;
 slideshow_controls #(.SCAN_CYCLES(8),.DEBOUNCE_SCANS(2),.AUTO_FRAMES(3)) dut(
 .clk(clk),.reset(reset),.ready(ready),.frame_end(frame_end),.key_col(cols),.key_row(row),
 .image_index(image),.auto_mode(auto_mode),.frame_toggle(toggle),.key_pressed());
 task tick;begin clk=0;#5;clk=1;#5;end endtask
 task run;input integer n;integer j;begin for(j=0;j<n;j=j+1)tick;end endtask
 task frame;begin frame_end=1;tick;frame_end=0;tick;end endtask
 task key;input [2:0] k;begin keys=k;run(150);keys=0;run(150);end endtask
 task check;input ok;begin if(!ok)$fatal(1,"direct switch failed");end endtask
 initial begin
 run(3);reset=0;run(20);key(2);frame;check(image==0);
 ready=1;key(1);check(image==0);frame;check(image==2);
 keys=2;run(150);frame;check(image==0);run(200);frame;check(image==0);
 keys=0;run(150);key(2);check(image==0);frame;check(image==1);
 key(4);check(auto_mode);repeat(3)frame;check(image==1);frame;check(image==2);
 key(4);check(!auto_mode);repeat(10)frame;check(image==2);
 $display("PASS direct switching: next blank commit, wrap, hold, auto/manual, not ready");$finish;
 end
endmodule
