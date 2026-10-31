// Ex3 verified read-only: F: partition starts at LBA 245760.
// Six photos: original IMAGE0/1/2 followed by S800600/S1280720/S480800.
// Last verified addresses retained; card disconnected during this build.
// Re-locate and rebuild after replacing/moving any file or changing cards.
module hdmi_media_top #(
 parameter MEDIA_LBA_VERIFIED=1,
 parameter [31:0] VIDEO_LBA=251744,IMAGE0_LBA=248032,IMAGE1_LBA=246112,IMAGE2_LBA=249888,
 parameter [31:0] IMAGE3_LBA=269472,IMAGE4_LBA=272288,IMAGE5_LBA=277728
)(
 input clk_50m,rst_n,sd_miso,input [3:0] key_col,
 output [3:0] key_row,output sd_cs,sd_sck,sd_mosi,led,
 output [2:0] hdmi_data_p,output hdmi_clk_p
);
 hdmi_video_top #(.COMBINED(1),.HQ(1),.IMAGE_SCALE(1),.PHOTO_COUNT(6),
  .IMAGE3_LBA(IMAGE3_LBA),.IMAGE4_LBA(IMAGE4_LBA),.IMAGE5_LBA(IMAGE5_LBA),.VIDEO0_LBA(VIDEO_LBA),
  .IMAGE0_LBA(IMAGE0_LBA),.IMAGE1_LBA(IMAGE1_LBA),.IMAGE2_LBA(IMAGE2_LBA)) player(
  .clk_50m(clk_50m),.rst_n(rst_n),.sd_miso(sd_miso),.key_col(key_col),
  .key_row(key_row),.sd_cs(sd_cs),.sd_sck(sd_sck),.sd_mosi(sd_mosi),
  .led(led),.hdmi_data_p(hdmi_data_p),.hdmi_clk_p(hdmi_clk_p));
endmodule
