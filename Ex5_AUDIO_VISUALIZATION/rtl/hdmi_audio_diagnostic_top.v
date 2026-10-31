// Same card/video path, but HDMI sends a continuous quiet 1kHz sine.
// Compile this top only when testing receiver audio compatibility.
module hdmi_audio_diagnostic_top(
 input wire clk_50m,rst_n,sd_miso,input wire [3:0] key_col,
 output wire [3:0] key_row,output wire sd_cs,sd_sck,sd_mosi,led,
 output wire [2:0] hdmi_data_p,output wire hdmi_clk_p
);
 hdmi_video_top #(.AUDIO_TEST(1)) player(
  .clk_50m(clk_50m),.rst_n(rst_n),.sd_miso(sd_miso),.key_col(key_col),
  .key_row(key_row),.sd_cs(sd_cs),.sd_sck(sd_sck),.sd_mosi(sd_mosi),
  .led(led),.hdmi_data_p(hdmi_data_p),.hdmi_clk_p(hdmi_clk_p));
endmodule
