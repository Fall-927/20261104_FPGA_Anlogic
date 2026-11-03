module media_controls #(
 parameter PHOTO_COUNT=3, SCAN_CYCLES=25200, DEBOUNCE_SCANS=20, AUTO_FRAMES=300
)(
 input clk,reset,ready,frame_end,input [3:0] key_col,
 input [1:0] period_selector,
 input schedule_enabled,hold_schedule,input [1:0] group_selector,
 output reg [3:0] key_row,output reg video_mode,paused,auto_mode,
 output reg [2:0] image_index,output reg frame_toggle,
 output reg [15:0] key_pressed,output reg [5:0] fade_level
);
 reg [3:0] meta,cols,sample,stable,previous;
 reg [31:0] scan_count,auto_count;
 reg [7:0] debounce;
 reg [1:0] row;
 reg [2:0] requested;
 reg [3:0] samples[0:2],states[0:2];
 reg [7:0] counts[0:2];
 reg [1:0] transition_state;
 reg [2:0] target;
 integer k;
 wire [3:0] pressed=stable & ~previous;
 reg [1:0] last_group;
 wire [2:0] first=group_selector==1 ? 0:group_selector==2 ? 3:group_selector==3 ? 6:0;
 wire [2:0] last=group_selector==1 ? 2:group_selector==2 ? 5:PHOTO_COUNT-1;
 wire [31:0] dwell=(period_selector==0 ? AUTO_FRAMES : period_selector==1 ? AUTO_FRAMES*2 : period_selector==2 ? AUTO_FRAMES*3 : AUTO_FRAMES*6)*
  ((image_index==1 || image_index==4) ? 2:1);
 always @(posedge clk or posedge reset) begin
  if(reset) begin
   meta<=15;cols<=15;sample<=0;stable<=0;previous<=0;
   key_row<=4'b1110;row<=0;scan_count<=0;debounce<=0;
   video_mode<=0;paused<=0;auto_mode<=1;image_index<=0;
   requested<=0;frame_toggle<=0;auto_count<=0;last_group<=0;
   key_pressed<=0;fade_level<=32;transition_state<=0;target<=0;
   for(k=0;k<3;k=k+1)begin samples[k]<=0;states[k]<=0;counts[k]<=0;end
  end else begin
   meta<=key_col;cols<=meta;previous<=stable;
   key_pressed<=0;
   if(scan_count==SCAN_CYCLES-1) begin
    scan_count<=0;row<=row+1'b1;key_row<={key_row[2:0],key_row[3]};
    if(row<3)begin
     if((~cols)!=samples[row])begin samples[row]<=~cols;counts[row]<=0;end
     else if(counts[row]==DEBOUNCE_SCANS-1)begin
      states[row]<=samples[row];key_pressed[row*4 +:4]<=samples[row] & ~states[row];
     end else counts[row]<=counts[row]+1'b1;
    end
    if(row==3) begin
     if((~cols)!=sample) begin sample<=~cols;debounce<=0;end
     else if(debounce==DEBOUNCE_SCANS-1) stable<=sample;
     else debounce<=debounce+1'b1;
    end
   end else scan_count<=scan_count+1'b1;
   if(pressed[3]) begin video_mode<=!video_mode;auto_count<=0;end
   else if(pressed[2]) begin
    if(video_mode) paused<=!paused;
    auto_count<=0;
   end
   if(frame_end)auto_mode<=schedule_enabled;
   if(!video_mode && ready && !pressed[3] && !hold_schedule) begin
    if(group_selector!=last_group)begin last_group<=group_selector;requested<=first;auto_count<=0;end
    else if(pressed[0]) begin requested<=requested<=first || requested>last ? last:requested-1'b1;auto_count<=0;end
    else if(pressed[1]) begin requested<=requested>=last || requested<first ? first:requested+1'b1;auto_count<=0;end
    else if(frame_end && auto_mode && !pressed[2] && transition_state==0 && requested==image_index) begin
     if(auto_count >= dwell-1) begin requested<=requested>=last ? first:requested+1'b1;auto_count<=0;end
     else auto_count<=auto_count+1'b1;
    end
   end else if(!hold_schedule)auto_count<=0;
   if(video_mode || !ready || pressed[3])begin
    fade_level<=32;transition_state<=0;
    if(frame_end)image_index<=requested;
   end else if(frame_end && !hold_schedule)begin
    case(transition_state)
     0:if(requested!=image_index)begin target<=requested;transition_state<=1;end
     1:begin fade_level<=fade_level-1'b1;if(fade_level==1)transition_state<=2;end
     2:begin image_index<=target;transition_state<=3;end
     3:begin fade_level<=fade_level+1'b1;if(fade_level==31)transition_state<=0;end
    endcase
   end
   if(frame_end)frame_toggle<=!frame_toggle;
  end
 end
endmodule
