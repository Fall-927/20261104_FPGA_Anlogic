// EG4S20 HDMI BMP player. The SD card is read once at boot; the frame is
// served from SDRAM. All parsing, conversion and timing run in the FPGA.
module hdmi_bmp_top #(
 parameter [31:0] IMAGE_LBA=32'd248032
)(
 input wire clk_50m,rst_n,sd_miso,
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
 wire card_reset=sysr[2] || !init_sync[1];
 wire [7:0] data_byte;
 wire data_valid,card_done,card_error;
 sd_bmp_fixed_lba_reader #(.IMAGE_LBA(IMAGE_LBA)) card(
 .clk(clk_50m),.reset(card_reset),.sd_miso(sd_miso),.sd_cs(sd_cs),
 .sd_sck(sd_sck),.sd_mosi(sd_mosi),.data_byte(data_byte),
 .data_valid(data_valid),.done(card_done),.error(card_error));
 reg started;
 always @(posedge clk_50m or posedge card_reset)
  if(card_reset) started<=0;else started<=1;
 wire format_error,pixel_valid,frame_done;
 wire [15:0] pixel;
 bmp24_stream_to_rgb565 parser(.clk(clk_50m),.reset(card_reset),
 .start(!started),.byte_in(data_byte),.byte_valid(data_valid),
 .format_error(format_error),.pixel_valid(pixel_valid),
 .pixel_rgb565(pixel),.frame_done(frame_done));
 wire [15:0] rgb;
 wire hs,vs,de;
 wire [7:0] unused_r,unused_g,unused_b;
 video_480p_bars timing(.clk(pixel_clk),.reset(pr[2]),
 .hsync(hs),.vsync(vs),.de(de),.red(unused_r),.green(unused_g),.blue(unused_b));
 reg [1:0] loaded_sync,error_sync;
 reg [9:0] prefill;
 reg display,vs_d,underflow;
 always @(posedge pixel_clk or posedge pr[2]) begin
  if(pr[2]) begin loaded_sync<=0;error_sync<=0;prefill<=0;display<=0;vs_d<=1;underflow<=0;end
  else begin
   loaded_sync<={loaded_sync[0],loaded};
   error_sync<={error_sync[0],card_error || format_error || overflow};
   vs_d<=vs;
   if(loaded_sync[1] && !prefill[9]) prefill<=prefill+1'b1;
   if(prefill[9] && !vs_d && vs && !error_sync[1]) display<=1;
   if(display && de && empty) underflow<=1;
  end
 end
 bmp_framebuffer fb(.mem_clk(mem_clk),.mem_clk_shift(mem_clk_shift),
 .reset(mem_reset),.write_clk(clk_50m),.pixel_valid(pixel_valid && !format_error),
 .pixel(pixel),.pixel_clk(pixel_clk),.read_enable(display && de),
 .rgb565(rgb),.init_done(init_done),.loaded(loaded),.empty(empty),.overflow(overflow));
 // The read FIFO is show-ahead: its output is valid before the read pulse.
 // Do not gate pixels with the asynchronous empty flag; doing so can create
 // a one-pixel seam at a clock-domain status transition.
 wire show=display && de && !error_sync[1] && !underflow;
 wire [7:0] red=show ? {rgb[15:11],rgb[15:13]} : 8'd0;
 wire [7:0] green=show ? {rgb[10:5],rgb[10:9]} : 8'd0;
 wire [7:0] blue=show ? {rgb[4:0],rgb[4:2]} : 8'd0;
 wire [9:0] sb,sg,sred;
 tmds_encoder eb(.clk(pixel_clk),.reset(pr[2]),.de(de),.c0(hs),.c1(vs),.data(blue),.symbol(sb));
 tmds_encoder eg(.clk(pixel_clk),.reset(pr[2]),.de(de),.c0(1'b0),.c1(1'b0),.data(green),.symbol(sg));
 tmds_encoder er(.clk(pixel_clk),.reset(pr[2]),.de(de),.c0(1'b0),.c1(1'b0),.data(red),.symbol(sred));
 reg toggle;
 always @(posedge pixel_clk or posedge pr[2])
  if(pr[2]) toggle<=0;else toggle<=!toggle;
 tmds_serializer_eg4 tx(.clk_5x(serial_clk),.reset(sr[2]),.pixel_toggle(toggle),
 .symbol_b(sb),.symbol_g(sg),.symbol_r(sred),
 .serial_data(hdmi_data_p),.serial_clock(hdmi_clk_p));
 assign led=display && !error_sync[1] && !underflow;
endmodule
