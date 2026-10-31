// Transaction-level end-to-end simulation. No physical PLL/SDRAM modelling.
module video_player_tb(
 input clk,reset,input [3:0] key_col,output [3:0] key_row,
 output [9:0] x,y,output de,playing,paused,fail,sample_tick,
 output [15:0] rgb,pcm_left,pcm_right,output [1:0] slot,
 output [31:0] packet_number,output [3:0] ready,released,
 output [1:0] pcm_phase,output video_empty,audio_empty
);
 wire [2:0] hdmi_data;
 hdmi_video_top dut(.clk_50m(clk),.rst_n(!reset),.sd_miso(1'b1),
  .key_col(key_col),.key_row(key_row),.hdmi_data_p(hdmi_data));
 assign x=dut.x;assign y=dut.y;assign de=dut.de;
 assign playing=dut.playing;assign paused=dut.pause_latched;assign fail=dut.fail;
 assign sample_tick=dut.sample_tick;assign rgb=dut.rgb;
 assign pcm_left=dut.pcm_left;assign pcm_right=dut.pcm_right;
 assign slot=dut.slot;assign packet_number=dut.packet_number;
 assign ready=dut.ready;assign released=dut.released;
 assign pcm_phase=dut.pcm_phase;assign video_empty=dut.video_empty;
 assign audio_empty=dut.audio_empty;
endmodule
module PLL(input refclk,reset,output extlock,clk0_out,clk1_out);
 assign extlock=!reset;assign clk0_out=refclk;assign clk1_out=refclk;
endmodule
module SDRAM_PLL(input refclk,reset,output clk0_out,clk1_out);
 assign clk0_out=refclk;assign clk1_out=refclk;
endmodule
module tmds_serializer_eg4(input clk_5x,reset,pixel_toggle,
 input [9:0] symbol_b,symbol_g,symbol_r,output [2:0] serial_data,output serial_clock);
 assign serial_data=0;assign serial_clock=clk_5x;
endmodule
// Replace only card PHY/commands with a throttled valid/ready AV15 stream.
module sd_av_reader #(parameter FAST_DIV=0,LOOP=1)(
 input [31:0] start_lba,sector_count,input clk,reset,sd_miso,data_ready,
 output sd_cs,sd_sck,sd_mosi,output reg [7:0] data_byte,
 output reg data_valid,done,error
);
 reg [31:0] offset;reg [7:0] throttle;
 reg [31:0] frame,within_packet,word_index;
 reg [15:0] value;
 assign sd_cs=1;assign sd_sck=0;assign sd_mosi=1;
 always @* begin
  frame=(offset-512)/173056;within_packet=(offset-512)%173056;
  word_index=within_packet/2;
  if(word_index<76800) value=word_index+frame*1000;
  else if(word_index>=86400) value=0;
  else if(!word_index[0]) value=(word_index-76800)/2+frame*4800;
  else value=16'hffff-((word_index-76800)/2+frame*4800);
 end
 function [7:0] header;
  input [31:0] p;
  begin case(p)
   0:header=65;1:header=86;2:header=49;3:header=48;
   4:header=2;8:header=64;9:header=1;10:header=240;12:header=10;14:header=2;
   16:header=128;17:header=187;20:header=8;25:header=88;26:header=2;29:header=75;
   default:header=0;
  endcase end
 endfunction
 always @(posedge clk or posedge reset)
  if(reset) begin offset<=0;throttle<=0;data_byte<=0;data_valid<=0;done<=0;error<=0;end
  else begin
   data_valid<=0;
   if(throttle!=0) throttle<=throttle-1'b1;
   else if(data_ready && !done) begin
    data_byte<=offset<512 ? header(offset) : (offset[0] ? value[15:8]:value[7:0]);
    data_valid<=1;offset<=offset+1'b1;throttle<=2;
    if(offset==512+8*173056-1) begin
     if(LOOP) offset<=512;else done<=1;
    end
   end
  end
endmodule
