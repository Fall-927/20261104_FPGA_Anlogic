module av15_memory #(parameter HQ=1, COMBINED=0, PHOTO_COUNT=3)(
 input wire mem_clk,mem_clk_shift,reset,write_clk,
 input wire [15:0] word_data,input wire word_valid,output wire word_ready,
 input wire pixel_clk,video_pop,audio_pop,refresh_toggle,video_enable,
 input wire [1:0] video_slot,input wire [3:0] released,
 output reg [3:0] ready,
 output wire [15:0] rgb565,pcm_word,output wire video_empty,audio_empty,
 output wire init_done,output reg overflow,
 input wire photo_mode,input wire [2:0] image_index,output reg photos_loaded
);
 wire [10:0] wr_used,video_used,audio_used,wr_write_used;
 wire wr_full,wa,ra,idle;wire [15:0] din,dout;
 reg wa_d,ra_d;reg [1:0] write_slot,audio_slot;
 localparam FRAME_WORDS=HQ ? 76800:19200;
 localparam AUDIO_WORDS=HQ ? 9600:6400;
 localparam SLOT_WORDS=FRAME_WORDS+AUDIO_WORDS;
 localparam WRITE_BURSTS=SLOT_WORDS/128;
 localparam LINE_WORDS=HQ ? 320:160;
 localparam SEGMENTS=LINE_WORDS/32;
 localparam ROW_REPEAT=HQ ? 2:4;
 localparam DISPLAY_WORDS=HQ ? 115200:76800;
 reg [9:0] write_burst;
 reg [13:0] audio_words;
 reg [21:0] wr_addr,video_addr;
 reg [3:0] audio_seen;
 reg [3:0] release_meta,release_sync;
 reg [1:0] slot_meta,slot_sync;
 reg [2:0] refresh_sync;
 reg refresh_seen;
 reg enable_meta,enable_sync;
 reg [1:0] phase;
 reg [5:0] clear_count;
 reg [1:0] row_repeat;
 reg [8:0] row;
 reg [4:0] segment;
 reg [18:0] video_words;
 reg [1:0] transaction;
 reg [1:0] turn;
 localparam NONE=0,WRITE=1,VIDEO=2,AUDIO=3;
 function [21:0] slot_base;
  input [1:0] s;
  begin case(s) 0:slot_base=0;1:slot_base=SLOT_WORDS;
   2:slot_base=SLOT_WORDS*2;3:slot_base=SLOT_WORDS*3;endcase end
 endfunction
 wire photo=COMBINED && photo_mode;
 reg [2:0] image_meta,image_sync;
 function [21:0] photo_base;
  input [2:0] i;
  begin case(i) 1:photo_base=307200;2:photo_base=614400;
   3:photo_base=921600;4:photo_base=1228800;5:photo_base=1536000;
   6:photo_base=1843200;7:photo_base=2150400;default:photo_base=0;endcase end
 endfunction
 wire write_available=photo ? !photos_loaded : ready[write_slot]==release_sync[write_slot];
 wire want_write=init_done && write_available && wr_used>=128;
 wire want_video=init_done && enable_sync && phase==0 &&
  video_words<(photo ? 307200:DISPLAY_WORDS) && video_used<256;
 wire want_audio=!photo && init_done && ready[audio_slot]!=audio_seen[audio_slot] && audio_used<256;
 wire [1:0] choice=want_video && (turn!=VIDEO || !want_audio) ? VIDEO :
  want_audio && (turn!=AUDIO || !want_write) ? AUDIO :
  want_write ? WRITE : want_video ? VIDEO : want_audio ? AUDIO : NONE;
 wire [21:0] read_address=(transaction==AUDIO) ?
  slot_base(audio_slot)+FRAME_WORDS+audio_words:video_addr;
 assign word_ready=wr_write_used<768 && !wr_full;
 SOFTFIFO #(.OUTREG_EN("OUTREG")) wf(.rst(reset),.clkw(write_clk),
  .we(word_valid && word_ready),.di(word_data),.clkr(mem_clk),.re(wa),
  .dout(din),.rdusedw(wr_used),.wrusedw(wr_write_used),.full_flag(wr_full));
 SOFTFIFO #(.OUTREG_EN("NOREG")) vf(.rst(reset || phase==2),
  .clkw(mem_clk),.we(ra && transaction==VIDEO),.di(dout),.wrusedw(video_used),
  .clkr(pixel_clk),.re(video_pop && !video_empty),.dout(rgb565),.empty_flag(video_empty));
 SOFTFIFO #(.OUTREG_EN("NOREG")) af(.rst(reset),
  .clkw(mem_clk),.we(ra && transaction==AUDIO),.di(dout),.wrusedw(audio_used),
  .clkr(pixel_clk),.re(audio_pop && !audio_empty),.dout(pcm_word),.empty_flag(audio_empty));
 always @(posedge write_clk or posedge reset)
  if(reset) overflow<=0;else if(word_valid && !word_ready) overflow<=1;
 always @(posedge mem_clk or posedge reset) begin
  if(reset) begin
   ready<=0;audio_seen<=0;release_meta<=0;release_sync<=0;slot_meta<=0;slot_sync<=0;
   refresh_sync<=0;refresh_seen<=0;enable_meta<=0;enable_sync<=0;
   wa_d<=0;ra_d<=0;write_slot<=0;audio_slot<=0;write_burst<=0;
   audio_words<=0;wr_addr<=0;video_addr<=0;phase<=3;clear_count<=0;
   row_repeat<=0;row<=0;segment<=0;video_words<=DISPLAY_WORDS;
   transaction<=NONE;turn<=NONE;photos_loaded<=0;image_meta<=0;image_sync<=0;
  end else begin
   release_meta<=released;release_sync<=release_meta;
   image_meta<=image_index;image_sync<=image_meta;
   slot_meta<=video_slot;slot_sync<=slot_meta;
   enable_meta<=video_enable;enable_sync<=enable_meta;
   refresh_sync<={refresh_sync[1:0],refresh_toggle};
   wa_d<=wa;ra_d<=ra;
   if(transaction==NONE && idle) transaction<=choice;
   if(transaction!=NONE && ((wa_d && !wa) || (ra_d && !ra))) begin
    turn<=transaction;
    if(transaction==WRITE) begin
     if(photo) begin
      wr_addr<=wr_addr+128;
      if(wr_addr==PHOTO_COUNT*307200-128) photos_loaded<=1;
     end else if(write_burst==WRITE_BURSTS-1) begin
      ready[write_slot]<=!ready[write_slot];write_slot<=write_slot+1'b1;
      write_burst<=0;wr_addr<=slot_base(write_slot+2'd1);
     end else begin write_burst<=write_burst+1'b1;wr_addr<=wr_addr+128;end
    end
    if(transaction==AUDIO) begin
     if(audio_words==AUDIO_WORDS-32) begin
      audio_seen[audio_slot]<=ready[audio_slot];audio_words<=0;audio_slot<=audio_slot+1'b1;
     end
     else audio_words<=audio_words+32;
    end
    if(transaction==VIDEO) begin
     video_words<=video_words+32;
     if(photo) begin
      if(segment==19) begin
       segment<=0;
       if(row!=0) begin row<=row-1'b1;video_addr<=video_addr-1248;end
      end else begin segment<=segment+1'b1;video_addr<=video_addr+32;end
     end else if(segment==SEGMENTS-1) begin
      segment<=0;
      if(row_repeat==(HQ ? (row[0] ? 0:1):ROW_REPEAT-1)) begin row_repeat<=0;row<=row+1'b1;video_addr<=video_addr+32;end
      else begin row_repeat<=row_repeat+1'b1;video_addr<=video_addr-(LINE_WORDS-32);end
     end else begin segment<=segment+1'b1;video_addr<=video_addr+32;end
    end
    transaction<=NONE;
   end
   if(refresh_sync[2]!=refresh_seen) begin refresh_seen<=refresh_sync[2];phase<=1;end
   if(phase==1 && transaction==NONE && idle) begin
    phase<=2;clear_count<=0;
    video_addr<=photo ? photo_base(image_sync)+306560:slot_base(slot_sync);
    row<=photo ? 479:0;row_repeat<=0;segment<=0;video_words<=0;
   end
   if(phase==2) begin
    if(clear_count==31) phase<=0;else clear_count<=clear_count+1'b1;
   end
  end
 end
 wire cke,cs,ras,cas,we;wire [1:0] ba;wire [10:0] addr;wire [31:0] dq;
 wire lane_high;
 sdram_controller #(.ADDR_WIDTH(22),.DATA_WIDTH(32)) ctrl(.clk(mem_clk),.rst_n(!reset),.idle(idle),
  .lane_high(lane_high),
  .sdram_wr_req(transaction==WRITE && !wa_d),.sdram_wr_ack(wa),
  .sdram_wr_addr(wr_addr),.sdram_wr_burst(9'd128),.sdram_din(din),
  .sdram_rd_req((transaction==VIDEO || transaction==AUDIO) && !ra_d),
  .sdram_rd_ack(ra),.sdram_rd_addr(read_address),.sdram_rd_burst(9'd32),
  .sdram_dout(dout),.sdram_init_done(init_done),.sdram_cke(cke),.sdram_cs_n(cs),
  .sdram_ras_n(ras),.sdram_cas_n(cas),.sdram_we_n(we),.sdram_ba(ba),
  .sdram_addr(addr),.sdram_data(dq));
 SDRAM physical(.clk(mem_clk_shift),.ras_n(ras),.cas_n(cas),.we_n(we),
  .addr(addr),.ba(ba),.dq(dq),.cs_n(cs),.dm0(lane_high),.dm1(lane_high),
  .dm2(!lane_high),.dm3(!lane_high),.cke(cke));
endmodule
