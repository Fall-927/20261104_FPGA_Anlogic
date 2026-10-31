// Shared matrix scanner. Row 3 columns 0..3 are physical KEY0..3.
module media_controls #(
 parameter SCAN_CYCLES=25200, DEBOUNCE_SCANS=20, AUTO_FRAMES=300
)(
 input clk,reset,ready,frame_end,input [3:0] key_col,
 output reg [3:0] key_row,output reg video_mode,paused,auto_mode,
 output reg [1:0] image_index,output reg frame_toggle
);
 reg [3:0] meta,cols,sample,stable,previous;
 reg [31:0] scan_count,auto_count;
 reg [7:0] debounce;
 reg [1:0] row,requested;
 wire [3:0] pressed=stable & ~previous;
 always @(posedge clk or posedge reset) begin
  if(reset) begin
   meta<=15;cols<=15;sample<=0;stable<=0;previous<=0;
   key_row<=4'b1110;row<=0;scan_count<=0;debounce<=0;
   video_mode<=0;paused<=0;auto_mode<=0;image_index<=0;
   requested<=0;frame_toggle<=0;auto_count<=0;
  end else begin
   meta<=key_col;cols<=meta;previous<=stable;
   if(scan_count==SCAN_CYCLES-1) begin
    scan_count<=0;row<=row+1'b1;key_row<={key_row[2:0],key_row[3]};
    if(row==3) begin
     if((~cols)!=sample) begin sample<=~cols;debounce<=0;end
     else if(debounce==DEBOUNCE_SCANS-1) stable<=sample;
     else debounce<=debounce+1'b1;
    end
   end else scan_count<=scan_count+1'b1;
   if(pressed[3]) begin video_mode<=!video_mode;auto_count<=0;end
   else if(pressed[2]) begin
    if(video_mode) paused<=!paused;else auto_mode<=!auto_mode;
    auto_count<=0;
   end
   if(!video_mode && ready && !pressed[3]) begin
    if(pressed[0]) begin requested<=requested==0 ? 2:requested-1'b1;auto_count<=0;end
    else if(pressed[1]) begin requested<=requested==2 ? 0:requested+1'b1;auto_count<=0;end
    else if(frame_end && auto_mode && !pressed[2]) begin
     if(auto_count==AUTO_FRAMES-1) begin requested<=requested==2 ? 0:requested+1'b1;auto_count<=0;end
     else auto_count<=auto_count+1'b1;
    end
   end else auto_count<=0;
   if(frame_end) begin image_index<=requested;frame_toggle<=!frame_toggle;end
  end
 end
endmodule
