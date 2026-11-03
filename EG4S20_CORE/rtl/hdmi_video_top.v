module hdmi_video_top #(
 parameter HQ=1,AUDIO_TEST=0,COMBINED=0,IMAGE_SCALE=0,PHOTO_COUNT=3,
 parameter [31:0] AUDIO_BASE_LBA=0,
 parameter [31:0] IMAGE3_LBA=0,IMAGE4_LBA=0,IMAGE5_LBA=0,IMAGE6_LBA=0,IMAGE7_LBA=0,
 parameter [31:0] IMAGE0_LBA=248032,IMAGE1_LBA=246112,IMAGE2_LBA=249888,
 parameter [31:0] VIDEO0_LBA=251744,VIDEO1_LBA=0,VIDEO2_LBA=0
)(
 input wire clk_50m,rst_n,sd_miso,input wire [3:0] key_col,input [7:0] sw,
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
 wire [2:0] photo_index;
 wire [15:0] setting_keys;
 wire [2:0] ad_scene;
 wire [1:0] period_selector,layout_mode,group_selector;
 wire [15:0] countdown_seconds;
 wire countdown_running,bgm_enabled,muted,schedule_enabled;
 wire [7:0] switches;
 dip_switches dips(.clk(pixel_clk),.reset(key_reset[2]),.raw(sw),.stable(switches));
 wire [4:0] volume;
 wire audio_visible;
 wire vblank;
 signage_control signage_controls(.clk(pixel_clk),.reset(key_reset[2]),.frame_end(vblank),
  .keys(setting_keys),.switches(switches),.scene(ad_scene),.period_selector(period_selector),.volume(volume),.audio_visible(audio_visible),
  .layout_mode(layout_mode),.group_selector(group_selector),.countdown_seconds(countdown_seconds),.countdown_running(countdown_running),
  .bgm_enabled(bgm_enabled),.muted(muted),.schedule_enabled(schedule_enabled));
 wire [5:0] fade_level;
 wire photos_loaded;
 (* ASYNC_REG="TRUE" *) reg [1:0] photos_loaded_sys;
 always @(posedge clk_50m or posedge hard_reset)
  if(hard_reset) photos_loaded_sys<=0;
  else if(restart_count!=0) photos_loaded_sys<=0;
  else photos_loaded_sys<={photos_loaded_sys[0],photos_loaded};
 reg [2:0] player_reset;
 reg [1:0] photo_loaded_sync;
 always @(posedge pixel_clk or posedge player_reset[2])
  if(player_reset[2]) photo_loaded_sync<=0;
  else photo_loaded_sync<={photo_loaded_sync[0],photos_loaded};
 wire [9:0] x,y;wire hs,vs,de;
 assign vblank=x==0 && y==492;
 generate if(COMBINED) begin: combined_keys
 media_controls #(.PHOTO_COUNT(PHOTO_COUNT)) controls(.clk(pixel_clk),.reset(key_reset[2]),.ready(photo_loaded_sync[1]),
  .frame_end(vblank),.period_selector(period_selector),.key_col(key_col),.key_row(key_row),.video_mode(video_mode),
  .schedule_enabled(schedule_enabled),.hold_schedule(ad_scene!=0),.group_selector(group_selector),
  .paused(paused),.auto_mode(photo_auto),.image_index(photo_index),.frame_toggle(key_frame_unused),
  .key_pressed(setting_keys),.fade_level(fade_level));
 assign selected=0;
 end else begin: legacy_keys
 assign video_mode=1;assign photo_auto=0;assign photo_index=0;
 assign setting_keys=0;assign fade_level=32;
 video_controls controls(.clk(pixel_clk),.reset(key_reset[2]),.ready(1'b1),
  .frame_end(vblank),.key_col(key_col),.key_row(key_row),
  .image_index(selected),.auto_mode(paused),.frame_toggle(key_frame_unused));
 end endgenerate
 reg mode_meta,mode_sync,current_mode;
 reg [1:0] select_meta,select_sync,current_select;
 reg [21:0] restart_count;
 reg [1:0] layout_meta,layout_sync,current_layout;
 wire photo_stopped,audio_idle;
 wire reload_layout=layout_sync!=current_layout;
 always @(posedge clk_50m or posedge hard_reset) begin
  if(hard_reset) begin
   select_meta<=0;select_sync<=0;current_select<=0;
   mode_meta<=!COMBINED;mode_sync<=!COMBINED;current_mode<=!COMBINED;
   restart_count<=250000;
   layout_meta<=1;layout_sync<=1;current_layout<=1;
  end else begin
   select_meta<=selected;select_sync<=select_meta;
   mode_meta<=video_mode && ad_scene==0;mode_sync<=mode_meta;
   layout_meta<=layout_mode;layout_sync<=layout_meta;
   if((select_sync!=current_select || mode_sync!=current_mode || (COMBINED && reload_layout && !current_mode)) &&
      (!COMBINED || (current_mode ? reader_stopped:(photo_stopped && audio_idle)))) begin
    current_mode<=mode_sync;
    current_select<=select_sync;restart_count<=250000;
    current_layout<=layout_sync;
   end else if(restart_count!=0) restart_count<=restart_count-1'b1;
  end
 end
 wire stream_reset=hard_reset || restart_count!=0;
 reg active_meta,active_video;
 always @(posedge pixel_clk or posedge hard_reset)
  if(hard_reset) begin active_meta<=!COMBINED;active_video<=!COMBINED;end
  else begin active_meta<=current_mode;active_video<=active_meta;end
 reg [2:0] pr,sr,mr,sysr;
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
 wire audio_cs,audio_sck,audio_mosi,audio_error;
 wire [15:0] music_left,music_right;
 wire [31:0] music_underruns;
 reg [2:0] scene_meta,scene_sync;
 reg bgm_meta,bgm_sync;
 always @(posedge clk_50m or posedge hard_reset)
  if(hard_reset)begin scene_meta<=0;scene_sync<=0;bgm_meta<=0;bgm_sync<=0;end
  else begin scene_meta<=ad_scene;scene_sync<=scene_meta;bgm_meta<=bgm_enabled;bgm_sync<=bgm_meta;end
 wire music_enable=COMBINED && !current_mode && !mode_sync && !reload_layout && photos_loaded_sys[1] && photo_stopped && (scene_sync!=0 || bgm_sync);
 wire [2:0] music_track=ad_scene;
 sd_audio_player #(.AUDIO_BASE_LBA(AUDIO_BASE_LBA)) music(.sys_clk(clk_50m),.pixel_clk(pixel_clk),.reset(stream_reset),
  .enable(music_enable),.track(music_track),.sample_tick(sample_tick),.sd_miso(sd_miso),
  .sd_cs(audio_cs),.sd_sck(audio_sck),.sd_mosi(audio_mosi),.idle(audio_idle),
  .left(music_left),.right(music_right),.error(audio_error),.underruns(music_underruns));
 generate if(COMBINED) begin: photos
 if(IMAGE_SCALE) begin: scaled
 scaled_photo_loader #(.PHOTO_COUNT(PHOTO_COUNT),.IMAGE3_LBA(IMAGE3_LBA),
 .IMAGE4_LBA(IMAGE4_LBA),.IMAGE5_LBA(IMAGE5_LBA),.IMAGE6_LBA(IMAGE6_LBA),.IMAGE7_LBA(IMAGE7_LBA),
 .IMAGE0_LBA(IMAGE0_LBA),.IMAGE1_LBA(IMAGE1_LBA),.IMAGE2_LBA(IMAGE2_LBA)) loader(
  .clk(clk_50m),.reset(loader_reset || current_mode),.sd_miso(sd_miso),.pixel_ready(word_ready),
  .layout_mode(current_layout),.stop_request(mode_sync || reload_layout || photos_loaded_sys[1]),.stopped(photo_stopped),
  .sd_cs(photo_cs),.sd_sck(photo_sck),.sd_mosi(photo_mosi),
  .pixel(photo_pixel),.pixel_valid(photo_valid),.error(photo_error));
 end else begin: fixed_size
 assign photo_stopped=1;
 photo_loader #(.IMAGE0_LBA(IMAGE0_LBA),.IMAGE1_LBA(IMAGE1_LBA),.IMAGE2_LBA(IMAGE2_LBA)) loader(
  .clk(clk_50m),.reset(loader_reset || current_mode),.sd_miso(sd_miso),
  .sd_cs(photo_cs),.sd_sck(photo_sck),.sd_mosi(photo_mosi),
  .pixel(photo_pixel),.pixel_valid(photo_valid),.error(photo_error));
 end
 end else begin: no_photos
 assign photo_cs=1;assign photo_sck=0;assign photo_mosi=1;
 assign photo_pixel=0;assign photo_valid=0;assign photo_error=0;
 assign photo_stopped=1;
 end endgenerate
 wire audio_owns_card=!current_mode && photos_loaded_sys[1] && photo_stopped;
 assign sd_cs=stream_reset ? 1'b1:current_mode ? video_cs:audio_owns_card ? audio_cs:photo_cs;
 assign sd_sck=stream_reset ? 1'b0:current_mode ? video_sck:audio_owns_card ? audio_sck:photo_sck;
 assign sd_mosi=stream_reset ? 1'b1:current_mode ? video_mosi:audio_owns_card ? audio_mosi:photo_mosi;
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
     refresh_toggle<=!refresh_toggle;
     if(playing && frame_phase==FRAMES_PER_PACKET-1 && !pause_latched) begin
      if(next_ready) begin
       slot<=next_slot;
       packet_number<=(packet_number+1==total_sync) ? 0:packet_number+1'b1;
       pending_release<=slot;advance_pending<=1;
      end else begin
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
 wire video_window=x>=16 && x<496 && y>=62 && y<422;
 wire [9:0] video_x=x-10'd16;
 wire video_pop=playing && de && !fail && (!active_video ||
  (video_window && (HQ ? video_x%3!=0 : x[1:0]==3)));
 av15_memory #(.HQ(HQ),.COMBINED(COMBINED),.PHOTO_COUNT(PHOTO_COUNT)) memory(.mem_clk(mem_clk),.mem_clk_shift(mem_clk_shift),.reset(mr[2]),
  .photo_mode(!current_mode),.image_index(photo_index),.photos_loaded(photos_loaded),
  .write_clk(clk_50m),.word_data(current_mode ? word_data:photo_pixel),
  .word_valid(current_mode ? word_valid:(photo_valid && (!IMAGE_SCALE || word_ready))),.word_ready(word_ready),
  .pixel_clk(pixel_clk),.video_pop(video_pop),.audio_pop(pcm_pop),
  .refresh_toggle(refresh_toggle),.video_enable(prepared),.video_slot(slot),
  .released(released),.ready(ready),.rgb565(rgb),.pcm_word(pcm_word),
  .video_empty(video_empty),.audio_empty(audio_empty),.init_done(init_done),.overflow(overflow));
 reg [15:0] last_rgb;
 always @(posedge pixel_clk or posedge player_reset[2])
  if(player_reset[2]) last_rgb<=0;
  else if(playing && de && !video_empty) last_rgb<=rgb;
 wire show=playing && !fail && de && (!active_video || video_window);
 wire [15:0] safe_rgb=video_empty ? last_rgb:rgb;
 wire [4:0] brightness,contrast;
 wire settings_visible;
 display_settings settings(.clk(pixel_clk),.reset(pr[2]),.frame_end(vblank),
  .key_pressed(setting_keys),.brightness(brightness),.contrast(contrast),.osd_enable(settings_visible));
 wire [7:0] ar,ag,ab;
 display_adjust adjust(.rgb565(safe_rgb),.brightness(brightness),.contrast(contrast),
  .show(show),.red(ar),.green(ag),.blue(ab));
 reg [23:0] adjusted;
 reg [9:0] x1,y1,x2,y2,x3,y3;
 reg hs1,vs1,de1,show1,hs2,vs2,de2,show2,hs3,vs3,de3,show3;
 reg [5:0] gain1;
 wire [13:0] fr=adjusted[23:16]*gain1,fg=adjusted[15:8]*gain1,fb=adjusted[7:0]*gain1;
 reg [23:0] faded,wave_pixels;
 wire [7:0] wr,wg,wb;
 audio_wave_overlay wave(.clk(pixel_clk),.reset(player_reset[2]),
  .enable(playing && !fail && audio_visible && ad_scene==0),.paused(active_video && pause_latched),
  .frame_end(vblank),.sample_tick(sample_tick),.pcm_left(active_video ? pcm_left:music_left),.pcm_right(active_video ? pcm_right:music_right),
  .x(x2),.y(y2),.de(de2),.red_in(faded[23:16]),.green_in(faded[15:8]),.blue_in(faded[7:0]),
  .red_out(wr),.green_out(wg),.blue_out(wb));
 always @(posedge pixel_clk or posedge pr[2])begin
  if(pr[2])begin
   adjusted<=0;faded<=0;wave_pixels<=0;gain1<=32;
   x1<=0;y1<=0;x2<=0;y2<=0;x3<=0;y3<=0;
   hs1<=1;vs1<=1;de1<=0;show1<=0;hs2<=1;vs2<=1;de2<=0;show2<=0;
   hs3<=1;vs3<=1;de3<=0;show3<=0;
  end else begin
   adjusted<={ar,ag,ab};gain1<=active_video ? 6'd32:fade_level;
   x1<=x;y1<=y;hs1<=hs;vs1<=vs;de1<=de;show1<=show;
   faded<={fr[12:5],fg[12:5],fb[12:5]};
   x2<=x1;y2<=y1;hs2<=hs1;vs2<=vs1;de2<=de1;show2<=show1;
   wave_pixels<={wr,wg,wb};x3<=x2;y3<=y2;hs3<=hs2;vs3<=vs2;de3<=de2;show3<=show2;
  end
 end
 wire [9:0] ox,oy;wire ohs,ovs,ode,oshow;
 wire [23:0] subtitle_pixels;
 signage_osd #(.PHOTO_COUNT(PHOTO_COUNT)) subtitles(.clk(pixel_clk),.reset(pr[2]),
  .x(x3),.y(y3),.hs(hs3),.vs(vs3),.de(de3),.rgb_in(wave_pixels),
  .image_index(photo_index),.auto_mode(photo_auto),.video_mode(active_video),.paused(pause_latched),
  .ready(playing),.failed(fail),.scene(ad_scene),.period_selector(period_selector),
  .layout_mode(active_video ? 2'd1:layout_mode),.countdown_seconds(countdown_seconds),.countdown_running(countdown_running),
  .group_selector(group_selector),.audio_error(audio_error),
  .brightness(brightness),.contrast(contrast),.volume(volume),.settings_visible(settings_visible),
  .out_x(ox),.out_y(oy),.out_hs(ohs),.out_vs(ovs),.out_de(ode),.rgb_out(subtitle_pixels));
 wire [7:0] red,green,blue;
 assign {red,green,blue}=subtitle_pixels;
 reg [23:0] final_pixels;
 reg [9:0] final_x,final_y;
 reg final_hs,final_vs,final_de;
 always @(posedge pixel_clk or posedge pr[2])begin
  if(pr[2])begin final_pixels<=0;final_x<=0;final_y<=0;final_hs<=1;final_vs<=1;final_de<=0;end
  else begin final_pixels<={red,green,blue};final_x<=ox;final_y<=oy;
   final_hs<=ohs;final_vs<=ovs;final_de<=ode;end
 end
 wire [9:0] sb,sg,sred;
 wire [15:0] source_left=active_video ? (ad_scene==0 ? pcm_left:16'd0):music_left;
 wire [15:0] source_right=active_video ? (ad_scene==0 ? pcm_right:16'd0):music_right;
 wire signed [21:0] volume_left=$signed(source_left)*$signed({1'b0,volume});
 wire signed [21:0] volume_right=$signed(source_right)*$signed({1'b0,volume});
 hdmi_audio_tx #(.EXTERNAL_PCM(!AUDIO_TEST)) audio_video(.clk(pixel_clk),.reset(pr[2]),
  .play(AUDIO_TEST || (active_video ? (playing && !pause_latched && !fail):COMBINED)),
  .pcm_left(muted ? 16'd0:volume_left[19:4]),.pcm_right(muted ? 16'd0:volume_right[19:4]),
  .x(final_x),.y(final_y),.hs(final_hs),.vs(final_vs),.de(final_de),
  .red(final_pixels[23:16]),.green(final_pixels[15:8]),.blue(final_pixels[7:0]),
  .symbol_b(sb),.symbol_g(sg),.symbol_r(sred),.audio_overflow(audio_overflow),.sample_tick(sample_tick));
 reg toggle;
 always @(posedge pixel_clk or posedge pr[2])
  if(pr[2]) toggle<=0;else toggle<=!toggle;
 tmds_serializer_eg4 tx(.clk_5x(serial_clk),.reset(sr[2]),.pixel_toggle(toggle),
  .symbol_b(sb),.symbol_g(sg),.symbol_r(sred),.serial_data(hdmi_data_p),.serial_clock(hdmi_clk_p));
 assign led=playing && !fail;
endmodule
