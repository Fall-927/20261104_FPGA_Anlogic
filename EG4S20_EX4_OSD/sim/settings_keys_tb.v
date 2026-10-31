`timescale 1ns/1ps
module settings_keys_tb;
 reg clk=0,reset=1,frame_end=0;
 reg [15:0] keys=0;
 wire [3:0] row;
 wire [3:0] cols=(row==14) ? ~keys[3:0] : (row==13) ? ~keys[7:4] : (row==11) ? ~keys[11:8] : ~keys[15:12];
 wire [15:0] pressed;
 wire [4:0] b,c;
 wire enabled;
 slideshow_controls #(.SCAN_CYCLES(8),.DEBOUNCE_SCANS(2)) scan(
 .clk(clk),.reset(reset),.ready(1'b1),.frame_end(frame_end),.key_col(cols),.key_row(row),
 .key_pressed(pressed));
 display_settings settings(clk,reset,frame_end,pressed,b,c,enabled);
 task tick;begin clk=0;#5;clk=1;#5;end endtask
 task run;input integer n;integer j;begin for(j=0;j<n;j=j+1)tick;end endtask
 task key;input integer n;begin keys=16'b1<<n;run(200);keys=0;run(200);end endtask
 task frame;begin frame_end=1;tick;frame_end=0;tick;end endtask
 task check;input ok;begin if(!ok)$fatal(1,"matrix key assertion failed");end endtask
 initial begin
 run(3);reset=0;run(20);
 key(9);frame;check(b==9);key(8);frame;check(b==8);
 key(5);frame;check(c==9);key(4);frame;check(c==8);
 keys=16'h0200;run(1000);frame;check(b==9);run(1000);frame;check(b==9);
 keys=0;run(200);key(0);frame;check(b==8 && c==8);
 key(1);frame;check(!enabled);key(1);frame;check(enabled);
 keys=16'h0100;run(5);keys=0;run(200);frame;check(b==8);
 $display("PASS matrix settings keys: all scan rows, hold, debounce, restore, OSD toggle");$finish;
 end
endmodule
