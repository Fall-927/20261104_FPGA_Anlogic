// AV10 v2: 320x240/10fps, 2x display, uninterrupted loop and 48k stereo.
// HQ=0 retains the legacy 160x120/15fps payload for regression only.
module hdmi_video_top #(
 parameter HQ=1,AUDIO_TEST=0,COMBINED=0,
 parameter [31:0] IMAGE0_LBA=248032,IMAGE1_LBA=246112,IMAGE2_LBA=249888,
 // VIDEOHQ.AV verified contiguous: partition 245760 + relative 13600.
 // Re-locate and rebuild after moving/replacing the SD file.
 // F: relative LBA 5984 + partition start 245760 = absolute LBA 251744.
 parameter [31:0] VIDEO0_LBA=251744,VIDEO1_LBA=0,VIDEO2_LBA=0
)(
 input wire clk_50m,rst_n,sd_miso,input wire [3:0] key_col,
 output wire [3:0] key_row,output wire sd_cs,sd_sck,sd_mosi,led,
 output wire [2:0] hdmi_data_p,output wire hdmi_clk_p
);
 wire pixel_clk,serial_clk,locked,mem_clk,mem_clk_shift;
 PLL video_pll(.refclk(clk_50m),.reset(!rst_n),.extlock(locked),
  .clk0_out(pixel_clk),.clk1_out(serial_clk));
 SDRAM_PLL memory_pll(.refclk(clk_50m),.reset(!rst_n),
  .clk0_out(mem_clk),.clk1_out(mem_clk_shift));
 wire hard_reset=!rst_n || !locked;
 reg [2:0] key_reset;
 always @(posedge pixel_clk or posedge hard_reset)
  if(hard_reset) key_reset<=7;else key_reset<={key_reset[1:0],1'b0};
 wire [1:0] selected;
 wire paused,key_frame_unused,video_mode,photo_auto;
 wire reader_stopped;
 wire [1:0] photo_index;
 wire photos_loaded;
 reg [2:0] player_reset;
 reg [1:0] photo_loaded_sync;
 always @(posedge pixel_clk or posedge player_reset[2])
  if(player_reset[2]) photo_loaded_sync<=0;
  else photo_loaded_sync<={photo_loaded_sync[0],photos_loaded};
 wire [9:0] x,y;wire hs,vs,de;
 wire vblank=x==0 && y==492;
 // Separate keyboard reset: selection and pause survive a clip restart.
 generate if(COMBINED) begin: combined_keys
 media_controls controls(.clk(pixel_clk),.reset(key_reset[2]),.ready(photo_loaded_sync[1]),
  .frame_end(vblank),.key_col(key_col),.key_row(key_row),.video_mode(video_mode),
  .paused(paused),.auto_mode(photo_auto),.image_index(photo_index),.frame_toggle(key_frame_unused));
 assign selected=0;
 end else begin: legacy_keys
 assign video_mode=1;assign photo_auto=0;assign photo_index=0;
 video_controls controls(.clk(pixel_clk),.reset(key_reset[2]),.ready(1'b1),
  .frame_end(vblank),.key_col(key_col),.key_row(key_row),
  .image_index(selected),.auto_mode(paused),.frame_toggle(key_frame_unused));
 end endgenerate
 reg mode_meta,mode_sync,current_mode;
 reg [1:0] select_meta,select_sync,current_select;
 reg [21:0] restart_count;
 always @(posedge clk_50m or posedge hard_reset) begin
  if(hard_reset) begin
   select_meta<=0;select_sync<=0;current_select<=0;
   mode_meta<=!COMBINED;mode_sync<=!COMBINED;current_mode<=!COMBINED;
   restart_count<=250000;
  end else begin
   select_meta<=selected;select_sync<=select_meta;
   mode_meta<=video_mode;mode_sync<=mode_meta;
   if((select_sync!=current_select || mode_sync!=current_mode) &&
      (!COMBINED || !current_mode || reader_stopped)) begin
    current_mode<=mode_sync;
    current_select<=select_sync;restart_count<=250000;
   end else if(restart_count!=0) restart_count<=restart_count-1'b1;
  end
 end
 wire stream_reset=hard_reset || restart_count!=0;
 // Requested keyboard mode is not the active transport mode. Commit only
 // after the video reader has drained its current sector and deselected SD.
 reg active_meta,active_video;
 always @(posedge pixel_clk or posedge hard_reset)
  if(hard_reset) begin active_meta<=!COMBINED;active_video<=!COMBINED;end
  else begin active_meta<=current_mode;active_video<=active_meta;end
 reg [2:0] pr,sr,mr,sysr;
 // Keep the HDMI link, raster and audio metadata alive while a clip loads.
 always @(posedge pixel_clk or posedge hard_reset)
  if(hard_reset) pr<=7;else pr<={pr[1:0],1'b0};
 always @(posedge serial_clk or posedge hard_reset)
  if(hard_reset) sr<=7;else sr<={sr[1:0],1'b0};
 always @(posedge pixel_clk or posedge stream_reset)
  if(stream_reset) player_reset<=7;else player_reset<={player_reset[1:0],1'b0};
 reg [7:0] link_frames;
 always @(posedge pixel_clk or posedge pr[2])
  if(pr[2]) link_frames<=0;
  else if(vblank && link_frames!=120) link_frames<=link_frames+1'b1;
 always @(posedge mem_clk or posedge stream_reset)
  if(stream_reset) mr<=7;else mr<={mr[1:0],1'b0};
 always @(posedge clk_50m or posedge stream_reset)
  if(stream_reset) sysr<=7;else sysr<={sysr[1:0],1'b0};
 wire init_done;reg [1:0] init_sync;
 always @(posedge clk_50m or posedge sysr[2])
  if(sysr[2]) init_sync<=0;else init_sync<={init_sync[0],init_done};
 wire loader_reset=sysr[2] || !init_sync[1];
 wire [31:0] start_lba=current_select==1 && VIDEO1_LBA!=0 ? VIDEO1_LBA :
  current_select==2 && VIDEO2_LBA!=0 ? VIDEO2_LBA : VIDEO0_LBA;
 wire [7:0] data_byte;wire data_valid,data_ready,card_done,card_error;
 wire [31:0] sector_count,frame_count;
 wire header_done,format_error,word_ready,word_valid;
 wire [15:0] word_data;
 wire video_cs,video_sck,video_mosi,photo_cs,photo_sck,photo_mosi;
 wire [15:0] photo_pixel;
 wire photo_valid,photo_error;
 generate if(COMBINED) begin: photos
 photo_loader #(.IMAGE0_LBA(IMAGE0_LBA),.IMAGE1_LBA(IMAGE1_LBA),.IMAGE2_LBA(IMAGE2_LBA)) loader(
  .clk(clk_50m),.reset(loader_reset || current_mode),.sd_miso(sd_miso),
  .sd_cs(photo_cs),.sd_sck(photo_sck),.sd_mosi(photo_mosi),
  .pixel(photo_pixel),.pixel_valid(photo_valid),.error(photo_error));
 end else begin: no_photos
 assign photo_cs=1;assign photo_sck=0;assign photo_mosi=1;
 assign photo_pixel=0;assign photo_valid=0;assign photo_error=0;
 end endgenerate
 assign sd_cs=stream_reset ? 1'b1:current_mode ? video_cs:photo_cs;
 assign sd_sck=stream_reset ? 1'b0:current_mode ? video_sck:photo_sck;
 assign sd_mosi=stream_reset ? 1'b1:current_mode ? video_mosi:photo_mosi;
 sd_av_reader #(.SAFE_STOP(COMBINED)) card(.clk(clk_50m),.reset(loader_reset || !current_mode || start_lba==0),
  .stop_request(COMBINED && current_mode && !mode_sync),.stopped(reader_stopped),
  .start_lba(start_lba),.sector_count(sector_count),.data_ready(data_ready),
  .sd_miso(sd_miso),.sd_cs(video_cs),.sd_sck(video_sck),.sd_mosi(video_mosi),
  .data_byte(data_byte),.data_valid(data_valid),.done(card_done),.error(card_error));
 av15_unpack #(.HQ(HQ)) unpack(.clk(clk_50m),.reset(loader_reset || !current_mode),.data_byte(data_byte),
  .data_valid(data_valid),.data_ready(data_ready),.word_ready(word_ready),
  .word_data(word_data),.word_valid(word_valid),.frame_count(frame_count),
  .sector_count(sector_count),.header_done(header_done),.error(format_error));
 video_480p_bars timing(.clk(pixel_clk),.reset(pr[2]),.pixel_x(x),.pixel_y(y),
  .hsync(hs),.vsync(vs),.de(de));
 wire [3:0] ready;
 reg [3:0] ready_meta,ready_sync,released;
 reg [31:0] total_meta,total_sync;
 reg header_meta,header_sync;
 reg [1:0] error_meta,error_sync;
 wire overflow;
 localparam FRAMES_PER_PACKET=HQ ? 6:4;
 reg [1:0] slot;
 reg [2:0] frame_phase;
 reg [31:0] packet_number;
 reg prepared,playing,refresh_toggle,fail;
 reg pause_latched,advance_pending;
 reg [1:0] pending_release;
 wire [1:0] next_slot=slot+2'd1;
 wire current_ready=ready_sync[slot]!=released[slot];
 wire next_ready=ready_sync[next_slot]!=released[next_slot];
 wire video_empty,audio_empty,audio_overflow;
 wire [15:0] rgb,pcm_word;
 wire sample_tick;
 reg [15:0] pcm_left,pcm_right;
 reg [1:0] pcm_phase;
 // Prefetch each L/R sample before sample_tick; FIFO ordering is L then R.
 wire pcm_pop=active_video && prepared && !pause_latched && !fail &&
  (pcm_phase==0 || pcm_phase==1) && !audio_empty;
 always @(posedge pixel_clk or posedge player_reset[2]) begin
  if(player_reset[2]) begin pcm_phase<=0;pcm_left<=0;pcm_right<=0;end
  else if(prepared && !pause_latched && !fail) begin
   if(pcm_pop) begin
    if(pcm_phase==0) begin pcm_left<=pcm_word;pcm_phase<=1;end
    else begin pcm_right<=pcm_word;pcm_phase<=2;end
   end
   if(sample_tick && playing) pcm_phase<=0;
  end
 end
 always @(posedge pixel_clk or posedge player_reset[2]) begin
  if(player_reset[2]) begin
   ready_meta<=0;ready_sync<=0;released<=0;total_meta<=0;total_sync<=0;
   header_meta<=0;header_sync<=0;error_meta<=0;error_sync<=0;
   slot<=0;frame_phase<=0;packet_number<=0;prepared<=0;playing<=0;
   refresh_toggle<=0;fail<=0;pause_latched<=0;
   advance_pending<=0;pending_release<=0;
  end else begin
   ready_meta<=ready;ready_sync<=ready_meta;
   total_meta<=frame_count;total_sync<=total_meta;
   header_meta<=header_done;header_sync<=header_meta;
   error_meta<={overflow,active_video ? (card_error || format_error):photo_error};error_sync<=error_meta;
   // Do not permanently blank the link on transient FIFO starvation. The
   // video converter holds its last RGB word and the audio path sends silence
   // until the next sample arrives. Parser/card errors remain fatal.
   if(|error_sync) fail<=1;
   if(!active_video) begin
    if(vblank && photo_loaded_sync[1] && link_frames==120) begin prepared<=1;refresh_toggle<=!refresh_toggle;end
    if(x==0 && y==0 && prepared && !fail) playing<=1;
   end else begin
   if(vblank) begin
    if(!prepared && header_sync && current_ready &&
       (&ready_sync) && link_frames==120) begin
     prepared<=1;refresh_toggle<=!refresh_toggle;pause_latched<=paused;
    end else if(prepared && !fail) begin
     // Re-read the current slot each raster; only commit at vertical blank.
     refresh_toggle<=!refresh_toggle;
     if(playing && frame_phase==FRAMES_PER_PACKET-1 && !pause_latched) begin
      if(next_ready) begin
       slot<=next_slot;
       packet_number<=(packet_number+1==total_sync) ? 0:packet_number+1'b1;
       pending_release<=slot;advance_pending<=1;
      end else begin
       // Keep the current slot for one more display packet. A slow card may
       // miss a prefetch deadline; stopping HDMI here caused the observed
       // short flash followed by permanent black output.
       slot<=slot; packet_number<=packet_number;
      end
     end
    end
   end
   if(x==0 && y==0 && prepared && !fail) begin
    if(!playing) begin playing<=1;frame_phase<=0;end
    else if(frame_phase==FRAMES_PER_PACKET-1) begin
     if(advance_pending) begin
      released[pending_release]<=ready_sync[pending_release];advance_pending<=0;
     end
     frame_phase<=0;pause_latched<=paused;
    end else if(!pause_latched) frame_phase<=frame_phase+1'b1;
    else pause_latched<=paused;
   end
   end
  end
 end
 wire video_pop=playing && de && (!active_video || (HQ ? x[0] : x[1:0]==3)) && !fail;
 av15_memory #(.HQ(HQ),.COMBINED(COMBINED)) memory(.mem_clk(mem_clk),.mem_clk_shift(mem_clk_shift),.reset(mr[2]),
  .photo_mode(!current_mode),.image_index(photo_index),.photos_loaded(photos_loaded),
  .write_clk(clk_50m),.word_data(current_mode ? word_data:photo_pixel),
  .word_valid(current_mode ? word_valid:photo_valid),.word_ready(word_ready),
  .pixel_clk(pixel_clk),.video_pop(video_pop),.audio_pop(pcm_pop),
  .refresh_toggle(refresh_toggle),.video_enable(prepared),.video_slot(slot),
  .released(released),.ready(ready),.rgb565(rgb),.pcm_word(pcm_word),
  .video_empty(video_empty),.audio_empty(audio_empty),.init_done(init_done),.overflow(overflow));
 reg [15:0] last_rgb;
 always @(posedge pixel_clk or posedge player_reset[2])
  if(player_reset[2]) last_rgb<=0;
  else if(playing && de && !video_empty) last_rgb<=rgb;
 wire show=playing && !fail && de;
 wire [15:0] safe_rgb=video_empty ? last_rgb:rgb;
 wire [7:0] red=show ? {safe_rgb[15:11],safe_rgb[15:13]}:8'd0;
 wire [7:0] green=show ? {safe_rgb[10:5],safe_rgb[10:9]}:8'd0;
 wire [7:0] blue=show ? {safe_rgb[4:0],safe_rgb[4:2]}:8'd0;
 wire [9:0] sb,sg,sred;
 hdmi_audio_tx #(.EXTERNAL_PCM(!AUDIO_TEST)) audio_video(.clk(pixel_clk),.reset(pr[2]),
  .play(AUDIO_TEST || (active_video && playing && !pause_latched && !fail)),.pcm_left(pcm_left),.pcm_right(pcm_right),
  .x(x),.y(y),.hs(hs),.vs(vs),.de(de),.red(red),.green(green),.blue(blue),
  .symbol_b(sb),.symbol_g(sg),.symbol_r(sred),.audio_overflow(audio_overflow),.sample_tick(sample_tick));
 reg toggle;
 always @(posedge pixel_clk or posedge pr[2])
  if(pr[2]) toggle<=0;else toggle<=!toggle;
 tmds_serializer_eg4 tx(.clk_5x(serial_clk),.reset(sr[2]),.pixel_toggle(toggle),
  .symbol_b(sb),.symbol_g(sg),.symbol_r(sred),.serial_data(hdmi_data_p),.serial_clock(hdmi_clk_p));
 assign led=playing && !fail;
endmodule
