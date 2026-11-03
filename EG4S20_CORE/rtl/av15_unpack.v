module av15_unpack #(parameter HQ=1,LOOP=1)(
 input wire clk,reset,input wire [7:0] data_byte,input wire data_valid,
 input wire word_ready,output wire data_ready,
 output reg [15:0] word_data,output reg word_valid,
 output reg [31:0] frame_count,output wire [31:0] sector_count,
 output reg header_done,error
);
 reg [8:0] header_pos;
 reg half;
 reg [7:0] low_byte;
 localparam VIDEO_BYTES=HQ ? 153600:38400;
 localparam AUDIO_BYTES=HQ ? 19200:12800;
 localparam PACKET_BYTES=HQ ? 173056:51200;
 localparam SECTORS=HQ ? 338:100;
 reg [17:0] packet_offset;
 reg [31:0] packet_number;
 reg exhausted;
 assign data_ready=!error && (!header_done || (word_ready && !exhausted));
 assign sector_count=header_done ? 1+frame_count*SECTORS : 32'hffffffff;
 function [7:0] expected;
  input [8:0] p;
  begin case(p)
   0:expected="A";1:expected="V";2:expected="1";3:expected=HQ ? "0":"5";
   4:expected=HQ ? 2:1;
   8:expected=HQ ? 8'h40:8'ha0;9:expected=HQ ? 1:0;
   10:expected=HQ ? 240:120;12:expected=HQ ? 10:15;14:expected=2;
   16:expected=8'h80;17:expected=8'hbb;
   24:expected=0;25:expected=HQ ? 8'h58:8'h96;26:expected=HQ ? 2:0;
   28:expected=0;29:expected=HQ ? 8'h4b:8'h32;
   default:expected=0;
  endcase end
 endfunction
 always @(posedge clk or posedge reset) begin
  if(reset) begin header_pos<=0;half<=0;low_byte<=0;word_data<=0;
   word_valid<=0;frame_count<=0;header_done<=0;error<=0;
   packet_offset<=0;packet_number<=0;exhausted<=0;end
  else begin
   word_valid<=0;
   if(data_valid) begin
    if(!data_ready) error<=1;
    else if(!header_done) begin
     if(header_pos>=20 && header_pos<=23)
      case(header_pos[1:0])
       0:frame_count[7:0]<=data_byte;1:frame_count[15:8]<=data_byte;
       2:frame_count[23:16]<=data_byte;3:frame_count[31:24]<=data_byte;
      endcase
     else if(data_byte!=expected(header_pos)) error<=1;
     if(header_pos==511) begin
      if(frame_count==0 || frame_count>(HQ ? 24818:83886)) error<=1;
      else header_done<=1;
     end else header_pos<=header_pos+1'b1;
    end else begin
     if(packet_offset<VIDEO_BYTES+AUDIO_BYTES) begin
      half<=!half;
      if(!half) low_byte<=data_byte;
      else begin word_data<={data_byte,low_byte};word_valid<=1;end
     end else if(data_byte!=0) error<=1;
     if(packet_offset==PACKET_BYTES-1) begin
      packet_offset<=0;
      if(packet_number==frame_count-1) begin
       packet_number<=0;if(!LOOP) exhausted<=1;
      end else packet_number<=packet_number+1'b1;
     end else packet_offset<=packet_offset+1'b1;
    end
   end
  end
 end
endmodule
