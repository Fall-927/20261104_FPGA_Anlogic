// EG4S20 three-image slideshow. The SD card is read once at boot; frames are
// served from SDRAM. All parsing, conversion and timing run in the FPGA.
module hdmi_slideshow_top #(
 parameter [31:0] IMAGE0_LBA=32'd248032,
 parameter [31:0] IMAGE1_LBA=32'd246112,
 parameter [31:0] IMAGE2_LBA=32'd249888
)(
 input wire clk_50m,rst_n,sd_miso,
 input wire [3:0] key_col,output wire [3:0] key_row,
 output wire sd_cs,sd_sck,sd_mosi,led,
 output wire [2:0] hdmi_data_p,output wire hdmi_clk_p
);
 wire pixel_clk,serial_clk,locked;
 PLL video_pll(.refclk(clk_50m),.reset(!rst_n),.extlock(locked),
 .clk0_out(pixel_clk),.clk1_out(serial_clk));
 wire mem_clk,mem_clk_shift;
 SDRAM_PLL memory_pll(.refclk(clk_50m),.reset(!rst_n),
 .clk0_out(mem_clk),.clk1_out(mem_clk_shift));
 wire async_reset=!rst_n || !locked;
 reg [15:0] mem_startup;
 always @(posedge mem_clk or posedge async_reset)
  if(async_reset) mem_startup<=0;
  else if(!mem_startup[15]) mem_startup<=mem_startup+1'b1;
 wire mem_reset=!mem_startup[15];
 reg [2:0] pr,sr,sysr;
 always @(posedge pixel_clk or posedge async_reset)
  if(async_reset) pr<=7;else pr<={pr[1:0],1'b0};
 always @(posedge serial_clk or posedge async_reset)
  if(async_reset) sr<=7;else sr<={sr[1:0],1'b0};
 always @(posedge clk_50m or posedge async_reset)
  if(async_reset) sysr<=7;else sysr<={sysr[1:0],1'b0};
 wire init_done,loaded,empty,overflow;
 reg [1:0] init_sync;
 always @(posedge clk_50m or posedge sysr[2])
  if(sysr[2]) init_sync<=0;else init_sync<={init_sync[0],init_done};
 wire loader_reset=sysr[2] || !init_sync[1];
 wire card_done,card_error,format_error;
 reg [1:0] load_index;
 reg [7:0] restart_count;
 wire card_reset=loader_reset || restart_count!=0;
 wire [31:0] selected_lba=(load_index==0) ? IMAGE0_LBA :
                              (load_index==1) ? IMAGE1_LBA : IMAGE2_LBA;
 always @(posedge clk_50m or posedge loader_reset) begin
  if(loader_reset) begin load_index<=0;restart_count<=0;end
  else if(restart_count!=0) restart_count<=restart_count-1'b1;
  else if(card_done && load_index<2 && !format_error && !card_error) begin
   load_index<=load_index+1'b1;restart_count<=255;
  end
 end
 wire [7:0] data_byte;
 wire data_valid;
 sd_playlist_reader card(
 .start_lba(selected_lba),
 .clk(clk_50m),.reset(card_reset),.sd_miso(sd_miso),.sd_cs(sd_cs),
 .sd_sck(sd_sck),.sd_mosi(sd_mosi),.data_byte(data_byte),
 .data_valid(data_valid),.done(card_done),.error(card_error));
 reg started;
 always @(posedge clk_50m or posedge card_reset)
  if(card_reset) started<=0;else started<=1;
 wire pixel_valid,frame_done;
 wire [15:0] pixel;
 bmp24_stream_to_rgb565 parser(.clk(clk_50m),.reset(card_reset),
 .start(!started),.byte_in(data_byte),.byte_valid(data_valid),
 .format_error(format_error),.pixel_valid(pixel_valid),
 .pixel_rgb565(pixel),.frame_done(frame_done));
 wire [15:0] rgb;
 wire hs,vs,de;
 wire [9:0] pixel_x,pixel_y;
 wire [7:0] unused_r,unused_g,unused_b;
 video_480p_bars timing(.clk(pixel_clk),.reset(pr[2]),
 .pixel_x(pixel_x),.pixel_y(pixel_y),
 .hsync(hs),.vsync(vs),.de(de),.red(unused_r),.green(unused_g),.blue(unused_b));
 reg display,vs_d,underflow;
 reg [1:0] loaded_sync,error_sync;
 wire [1:0] image_index;
 wire frame_toggle,auto_mode;
 wire [15:0] key_pressed;
 wire [4:0] brightness,contrast;
 wire osd_enable;
 display_settings settings(.clk(pixel_clk),.reset(pr[2]),.frame_end(!vs_d && vs),
 .key_pressed(key_pressed),.brightness(brightness),.contrast(contrast),.osd_enable(osd_enable));
 // The VS rising edge is in vertical blank, ~1 ms before the next frame.
 slideshow_controls controls(.clk(pixel_clk),.reset(pr[2]),
 .ready(loaded_sync[1]),.frame_end(!vs_d && vs),
 .key_col(key_col),.key_row(key_row),.image_index(image_index),
 .auto_mode(auto_mode),.frame_toggle(frame_toggle),
 .key_pressed(key_pressed));
 reg load_error;
 always @(posedge clk_50m or posedge loader_reset)
  if(loader_reset) load_error<=0;
  else if(card_error || format_error) load_error<=1;
 reg [9:0] prefill;
 always @(posedge pixel_clk or posedge pr[2]) begin
  if(pr[2]) begin loaded_sync<=0;error_sync<=0;prefill<=0;display<=0;vs_d<=1;underflow<=0;end
  else begin
   loaded_sync<={loaded_sync[0],loaded};
   error_sync<={error_sync[0],load_error || overflow};
   vs_d<=vs;
   if(loaded_sync[1] && !prefill[9]) prefill<=prefill+1'b1;
   if(prefill[9] && !vs_d && vs && !error_sync[1]) display<=1;
   if(display && de && empty) underflow<=1;
  end
 end
 slideshow_framebuffer fb(.mem_clk(mem_clk),.mem_clk_shift(mem_clk_shift),
 .reset(mem_reset),.write_clk(clk_50m),.pixel_valid(pixel_valid && !format_error),
 .pixel(pixel),.pixel_clk(pixel_clk),.read_enable(display && de),
 .frame_toggle(frame_toggle),.image_index(image_index),
 .rgb565(rgb),.init_done(init_done),.loaded(loaded),.empty(empty),.overflow(overflow));
 // The read FIFO is show-ahead: its output is valid before the read pulse.
 // Do not gate pixels with the asynchronous empty flag; doing so can create
 // a one-pixel seam at a clock-domain status transition.
 wire show=display && de && !error_sync[1] && !underflow;
 wire [7:0] red,green,blue;
 wire [7:0] adjusted_r,adjusted_g,adjusted_b;
 reg [23:0] adjusted_pipe,osd_pipe;
 reg [9:0] x1,y1,x2,y2;
 reg hs1,vs1,de1,show1,hs2,vs2,de2;
 always @(posedge pixel_clk or posedge pr[2])begin
  if(pr[2])begin
   adjusted_pipe<=0;osd_pipe<=0;x1<=0;y1<=0;x2<=0;y2<=0;
   hs1<=1;vs1<=1;de1<=0;show1<=0;hs2<=1;vs2<=1;de2<=0;
  end else begin
   adjusted_pipe<={adjusted_r,adjusted_g,adjusted_b};
   x1<=pixel_x;y1<=pixel_y;hs1<=hs;vs1<=vs;de1<=de;show1<=show;
   osd_pipe<={red,green,blue};x2<=x1;y2<=y1;hs2<=hs1;vs2<=vs1;de2<=de1;
  end
 end
 display_adjust adjust(.rgb565(rgb),.brightness(brightness),.contrast(contrast),
 .show(show),.red(adjusted_r),.green(adjusted_g),.blue(adjusted_b));
 display_osd osd(.x(x1),.y(y1),.enable(osd_enable),.show(show1),
 .brightness(brightness),.contrast(contrast),
 .in_r(adjusted_pipe[23:16]),.in_g(adjusted_pipe[15:8]),.in_b(adjusted_pipe[7:0]),.red(red),.green(green),.blue(blue));
 wire [9:0] sb,sg,sred;
 wire audio_overflow;
 hdmi_audio_tx audio_video(.clk(pixel_clk),.reset(pr[2]),
 .play(display && !error_sync[1] && !underflow),
 .x(x2),.y(y2),.hs(hs2),.vs(vs2),.de(de2),
 .red(osd_pipe[23:16]),.green(osd_pipe[15:8]),.blue(osd_pipe[7:0]),
 .symbol_b(sb),.symbol_g(sg),.symbol_r(sred),.audio_overflow(audio_overflow));
 reg toggle;
 always @(posedge pixel_clk or posedge pr[2])
  if(pr[2]) toggle<=0;else toggle<=!toggle;
 tmds_serializer_eg4 tx(.clk_5x(serial_clk),.reset(sr[2]),.pixel_toggle(toggle),
 .symbol_b(sb),.symbol_g(sg),.symbol_r(sred),
 .serial_data(hdmi_data_p),.serial_clock(hdmi_clk_p));
 assign led=display && !error_sync[1] && !underflow && !audio_overflow;
endmodule
