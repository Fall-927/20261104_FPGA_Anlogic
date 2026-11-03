module video_controls #(
 parameter integer SCAN_CYCLES=25200,
 parameter integer DEBOUNCE_SCANS=20,
 parameter integer AUTO_FRAMES=300
)(
 input wire clk,reset,ready,frame_end,
 input wire [3:0] key_col,output reg [3:0] key_row,
 output reg [1:0] image_index,output reg auto_mode,
 output reg frame_toggle
);
 reg [3:0] cols_meta,cols;
 reg [31:0] scan_count,auto_count;
 reg [1:0] row;
 reg [2:0] sample,stable,previous;
 reg [7:0] debounce;
 reg [1:0] requested;
 wire [2:0] pressed=stable & ~previous;
 function [1:0] next_image;
  input [1:0] i;
  begin next_image=(i==2) ? 0 : i+1'b1;end
 endfunction
 function [1:0] prev_image;
  input [1:0] i;
  begin prev_image=(i==0) ? 2 : i-1'b1;end
 endfunction
 always @(posedge clk or posedge reset) begin
  if(reset) begin
   cols_meta<=15;cols<=15;scan_count<=0;row<=0;key_row<=4'b1110;
   sample<=0;stable<=0;previous<=0;debounce<=0;
   image_index<=0;requested<=0;auto_mode<=0;auto_count<=0;frame_toggle<=0;
  end else begin
   cols_meta<=key_col;cols<=cols_meta;previous<=stable;
   if(scan_count==SCAN_CYCLES-1) begin
    scan_count<=0;row<=row+1'b1;key_row<={key_row[2:0],key_row[3]};
    if(row==3) begin
     if((~cols[2:0])!=sample) begin sample<=~cols[2:0];debounce<=0;end
     else if(debounce==DEBOUNCE_SCANS-1) stable<=sample;
     else debounce<=debounce+1'b1;
    end
   end else scan_count<=scan_count+1'b1;
   if(pressed[2]) begin auto_mode<=!auto_mode;auto_count<=0;end
   if(ready) begin
    if(pressed[0]) begin requested<=prev_image(requested);auto_count<=0;end
    else if(pressed[1]) begin requested<=next_image(requested);auto_count<=0;end
    else if(1'b0) begin
     if(auto_count==AUTO_FRAMES-1) begin requested<=next_image(requested);auto_count<=0;end
     else auto_count<=auto_count+1'b1;
    end
    if(frame_end) begin image_index<=requested;frame_toggle<=!frame_toggle;end
   end else auto_count<=0;
  end
 end
endmodule
