module hdmi_media_top #(
 parameter MEDIA_LBA_VERIFIED=1,
 parameter [31:0] AUDIO_BASE_LBA=312352,
 parameter [31:0] VIDEO_LBA=264608,IMAGE0_LBA=246112,IMAGE1_LBA=247968,IMAGE2_LBA=249824,
 parameter [31:0] IMAGE3_LBA=251680,IMAGE4_LBA=253536,IMAGE5_LBA=255392,
 parameter [31:0] IMAGE6_LBA=257248,IMAGE7_LBA=259104
)(
 input clk_50m,rst_n,sd_miso,input [3:0] key_col,input [7:0] sw,
 output [3:0] key_row,output sd_cs,sd_sck,sd_mosi,led,
 output [2:0] hdmi_data_p,output hdmi_clk_p
);
 hdmi_video_top #(.COMBINED(1),.HQ(1),.IMAGE_SCALE(1),.PHOTO_COUNT(8),.AUDIO_BASE_LBA(AUDIO_BASE_LBA),
  .IMAGE6_LBA(IMAGE6_LBA),.IMAGE7_LBA(IMAGE7_LBA),
  .IMAGE3_LBA(IMAGE3_LBA),.IMAGE4_LBA(IMAGE4_LBA),.IMAGE5_LBA(IMAGE5_LBA),.VIDEO0_LBA(VIDEO_LBA),
  .IMAGE0_LBA(IMAGE0_LBA),.IMAGE1_LBA(IMAGE1_LBA),.IMAGE2_LBA(IMAGE2_LBA)) player(
  .clk_50m(clk_50m),.rst_n(rst_n),.sd_miso(sd_miso),.key_col(key_col),.sw(sw),
  .key_row(key_row),.sd_cs(sd_cs),.sd_sck(sd_sck),.sd_mosi(sd_mosi),
  .led(led),.hdmi_data_p(hdmi_data_p),.hdmi_clk_p(hdmi_clk_p));
endmodule
