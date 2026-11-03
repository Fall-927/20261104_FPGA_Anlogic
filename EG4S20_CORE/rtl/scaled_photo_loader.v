module scaled_photo_loader #(
 parameter PHOTO_COUNT=3,
 parameter [31:0] IMAGE0_LBA=0,IMAGE1_LBA=0,IMAGE2_LBA=0,
 IMAGE3_LBA=0,IMAGE4_LBA=0,IMAGE5_LBA=0,IMAGE6_LBA=0,IMAGE7_LBA=0
)(
 input clk,reset,sd_miso,pixel_ready,input [1:0] layout_mode,
 input stop_request,output stopped,output sd_cs,sd_sck,sd_mosi,
 output [15:0] pixel,output pixel_valid,output error
);
 reg [2:0] index;
 reg [7:0] restart;
 wire card_reset=reset || restart!=0;
 wire card_done,card_error,format_error,frame_done;
 wire [31:0] lba=index==0 ? IMAGE0_LBA:index==1 ? IMAGE1_LBA:
 index==2 ? IMAGE2_LBA:index==3 ? IMAGE3_LBA:index==4 ? IMAGE4_LBA:
 index==5 ? IMAGE5_LBA:index==6 ? IMAGE6_LBA:IMAGE7_LBA;
 always @(posedge clk or posedge reset)
  if(reset) begin index<=0;restart<=0;end
  else if(restart!=0) restart<=restart-1'b1;
  else if(card_done && frame_done && index<PHOTO_COUNT-1 && !error && !stop_request) begin index<=index+1'b1;restart<=255;end
 wire [7:0] data_byte;
 wire data_valid,data_ready;
 wire [31:0] sectors;
 sd_av_reader #(.LOOP(0),.FAST_DIV(1),.SAFE_STOP(1)) card(.clk(clk),.reset(card_reset),
  .start_lba(lba),.sector_count(sectors),.data_ready(data_ready),
  .sd_miso(sd_miso),.sd_cs(sd_cs),.sd_sck(sd_sck),.sd_mosi(sd_mosi),
  .data_byte(data_byte),.data_valid(data_valid),.done(card_done),.error(card_error),
  .stop_request(stop_request),.stopped(stopped));
 reg buffered;
 reg [7:0] buffer;
 wire parser_ready;
 assign data_ready=(!buffered && !data_valid) || frame_done;
 always @(posedge clk or posedge card_reset)
  if(card_reset) begin buffered<=0;buffer<=0;end
  else begin
   if((buffered && parser_ready) || frame_done) buffered<=0;
   if(data_valid && !frame_done) begin buffered<=1;buffer<=data_byte;end
  end
 bmp_scale_stream parser(.clk(clk),.reset(card_reset),.byte_in(buffer),
  .layout_mode(layout_mode),
  .byte_valid(buffered && parser_ready),.byte_ready(parser_ready),
  .pixel(pixel),.pixel_valid(pixel_valid),.pixel_ready(pixel_ready),
  .frame_done(frame_done),.error(format_error),.sector_count(sectors));
 assign error=card_error || format_error;
endmodule
