module photo_loader #(
 parameter [31:0] IMAGE0_LBA=248032,IMAGE1_LBA=246112,IMAGE2_LBA=249888
)(
 input clk,reset,sd_miso,output sd_cs,sd_sck,sd_mosi,
 output [15:0] pixel,output pixel_valid,output error
);
 reg [1:0] index;
 reg [7:0] restart;
 wire card_reset=reset || restart!=0;
 wire done,card_error,format_error;
 wire [31:0] lba=index==0 ? IMAGE0_LBA:index==1 ? IMAGE1_LBA:IMAGE2_LBA;
 always @(posedge clk or posedge reset)
  if(reset) begin index<=0;restart<=0;end
  else if(restart!=0) restart<=restart-1'b1;
  else if(done && index<2 && !error) begin index<=index+1'b1;restart<=255;end
 wire [7:0] data_byte;
 wire data_valid;
 sd_playlist_reader card(.clk(clk),.reset(card_reset),.start_lba(lba),
  .sd_miso(sd_miso),.sd_cs(sd_cs),.sd_sck(sd_sck),.sd_mosi(sd_mosi),
  .data_byte(data_byte),.data_valid(data_valid),.done(done),.error(card_error));
 reg started;
 always @(posedge clk or posedge card_reset)
  if(card_reset) started<=0;else started<=1;
 wire frame_done;
 bmp24_stream_to_rgb565 parser(.clk(clk),.reset(card_reset),.start(!started),
  .byte_in(data_byte),.byte_valid(data_valid),.format_error(format_error),
  .pixel_valid(pixel_valid),.pixel_rgb565(pixel),.frame_done(frame_done));
 assign error=card_error || format_error;
endmodule
