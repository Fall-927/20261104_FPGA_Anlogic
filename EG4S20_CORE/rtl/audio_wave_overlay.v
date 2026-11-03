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
 wire [9:0] relative_x=x-10'd520;
 wire [11:0] point0=wave_ram[{front_bank,relative_x[6:2],2'b00}];
 wire [11:0] point1=wave_ram[{front_bank,relative_x[6:2],2'b10}];
 function [5:0] magnitude;
  input [5:0] sample;
  begin magnitude=sample[5] ? (~sample+6'd1):sample;end
 endfunction
 wire [5:0] a0=magnitude(point0[11:6]),a1=magnitude(point0[5:0]);
 wire [5:0] a2=magnitude(point1[11:6]),a3=magnitude(point1[5:0]);
 wire [5:0] peak0=a0>a1 ? a0:a1,peak1=a2>a3 ? a2:a3;
 wire [5:0] peak=peak0>peak1 ? peak0:peak1;
 wire [6:0] height={1'b0,peak};
 wire [9:0] top_y=10'd408-{3'b0,height};
 wire panel=enable && de && x>=520 && x<632 && y>=358 && y<414;
 wire baseline=y==410;
 wire trace=front_valid && relative_x[1:0]!=3 &&
  y<408 && (y>=top_y || y>=406);
 assign red_out=!panel ? red_in : trace ? (paused ? 8'd255:8'd224) : baseline ? 8'd152 : {1'b0,red_in[7:1]};
 assign green_out=!panel ? green_in : trace ? (paused ? 8'd192:8'd248) : baseline ? 8'd184 : {1'b0,green_in[7:1]};
 assign blue_out=!panel ? blue_in : trace ? (paused ? 8'd96:8'd255) : baseline ? 8'd208 : {1'b0,blue_in[7:1]};
endmodule
