module display_settings(
 input wire clk,reset,frame_end,
 input wire [15:0] key_pressed,
 output reg [4:0] brightness,contrast,
 output reg osd_enable
);
 reg [4:0] pending_b,pending_c;
 reg pending_osd;
 always @(posedge clk or posedge reset)begin
  if(reset)begin
   pending_b<=8;pending_c<=8;pending_osd<=1;
   brightness<=8;contrast<=8;osd_enable<=1;
  end else begin
   if(key_pressed[0])begin pending_b<=8;pending_c<=8;end
   else begin
    if(key_pressed[8] && !key_pressed[9] && pending_b>0)pending_b<=pending_b-1'b1;
    if(key_pressed[9] && !key_pressed[8] && pending_b<16)pending_b<=pending_b+1'b1;
    if(key_pressed[4] && !key_pressed[5] && pending_c>0)pending_c<=pending_c-1'b1;
    if(key_pressed[5] && !key_pressed[4] && pending_c<16)pending_c<=pending_c+1'b1;
   end
   if(key_pressed[1])pending_osd<=!pending_osd;
   if(frame_end)begin brightness<=pending_b;contrast<=pending_c;osd_enable<=pending_osd;end
  end
 end
endmodule
