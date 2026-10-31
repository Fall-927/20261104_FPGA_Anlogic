// Stereo min/max waveform envelope, not an FFT spectrum.
// 8 stereo sample pairs per bin, 128 bins = 21.33 ms at 48 kHz.
// Ping-pong banks publish only in vertical blank; no PCM backpressure.
module audio_wave_overlay(
 input wire clk,reset,enable,paused,frame_end,sample_tick,
 input wire [15:0] pcm_left,pcm_right,
 input wire [9:0] x,y,input wire de,
 input wire [7:0] red_in,green_in,blue_in,
 output wire [7:0] red_out,green_out,blue_out
);
 reg [11:0] wave_ram[0:255];
 reg write_bank,front_bank,front_valid,pending;
 reg [6:0] column;
 reg [2:0] count;
 reg signed [5:0] low_sample,high_sample;
 wire signed [5:0] left_sample=pcm_left[15:10];
 wire signed [5:0] right_sample=pcm_right[15:10];
 wire signed [5:0] pair_low=left_sample<right_sample ? left_sample:right_sample;
 wire signed [5:0] pair_high=left_sample>right_sample ? left_sample:right_sample;
 wire signed [5:0] bin_low=(count==0 || pair_low<low_sample) ? pair_low:low_sample;
 wire signed [5:0] bin_high=(count==0 || pair_high>high_sample) ? pair_high:high_sample;
 always @(posedge clk or posedge reset) begin
  if(reset) begin
   write_bank<=0;front_bank<=1;front_valid<=0;pending<=0;
   column<=0;count<=0;low_sample<=0;high_sample<=0;
  end else begin
   if(frame_end && pending && !paused) begin
    front_bank<=write_bank;write_bank<=!write_bank;
    front_valid<=1;pending<=0;column<=0;count<=0;
   end
   if(enable && !paused && sample_tick && !pending) begin
    low_sample<=bin_low;high_sample<=bin_high;
    if(count==7) begin
     wave_ram[{write_bank,column}]<={bin_high,bin_low};count<=0;
     if(column==127) pending<=1;else column<=column+1'b1;
    end else count<=count+1'b1;
   end
  end
 end
 wire [9:0] relative_x=x-10'd64;
 wire [11:0] point=wave_ram[{front_bank,relative_x[8:2]}];
 wire signed [10:0] upper_y=11'sd416-$signed({{5{point[11]}},point[11:6]});
 wire signed [10:0] lower_y=11'sd416-$signed({{5{point[5]}},point[5:0]});
 wire panel=enable && de && x>=64 && x<576 && y>=368 && y<464;
 wire border=x==64 || x==575 || y==368 || y==463;
 wire grid=(relative_x[5:0]==0) || y==416;
 wire trace=front_valid && $signed({1'b0,y})>=upper_y && $signed({1'b0,y})<=lower_y;
 // Dark translucent-style background: divide underlying RGB by four.
 assign red_out=!panel ? red_in : trace ? (paused ? 8'd255:8'd48) : border ? 8'd120 : grid ? 8'd48 : {2'b0,red_in[7:2]};
 assign green_out=!panel ? green_in : trace ? (paused ? 8'd192:8'd240) : border ? 8'd150 : grid ? 8'd64 : {2'b0,green_in[7:2]};
 assign blue_out=!panel ? blue_in : trace ? 8'd96 : border ? 8'd180 : grid ? 8'd80 : {2'b0,blue_in[7:2]};
endmodule
