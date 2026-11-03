module sd_audio_player #(parameter [31:0] AUDIO_BASE_LBA=0)(
 input sys_clk,pixel_clk,reset,enable,input [2:0] track,
 input sample_tick,sd_miso,output sd_cs,sd_sck,sd_mosi,
 output idle,output reg [15:0] left,right,output error,
 output reg [31:0] underruns
);
 `include "audio_catalog.vh"
 (* ASYNC_REG="TRUE" *) reg [2:0] track_meta,track_sync;
 reg en_meta,en_sync;
 reg [2:0] selected;
 reg [1:0] state;reg [9:0] guard;
 localparam WAIT=0,FLUSH=1,RUN=2,DRAIN=3;
 wire stopped,card_error,valid,done;wire [7:0] data;
 wire fifo_reset=reset || state!=RUN;
 wire [12:0] used;
 wire full,empty;wire [31:0] pair;
 reg [1:0] phase;reg [23:0] assembly;
 wire accept=valid && state==RUN;
 wire write_pair=accept && phase==3;
 wire [31:0] word={data,assembly};
 wire card_reset=reset || state==WAIT || state==FLUSH;
 wire usable=AUDIO_BASE_LBA!=0 && (selected!=0 || BGM_AVAILABLE);
 sd_av_reader #(.LOOP(1),.LOOP_SKIP(0),.SAFE_STOP(1),.FAST_DIV(1)) reader(
  .clk(sys_clk),.reset(card_reset),.start_lba(AUDIO_BASE_LBA+track_offset(selected)),
  .sector_count(track_sectors(selected)),.sd_miso(sd_miso),.data_ready(used<3072 && !full),
  .stop_request(state==DRAIN),.stopped(stopped),.sd_cs(sd_cs),.sd_sck(sd_sck),.sd_mosi(sd_mosi),
  .data_byte(data),.data_valid(valid),.done(done),.error(card_error));
 assign error=card_error && state==RUN;
 assign idle=state==WAIT;
 always @(posedge sys_clk or posedge reset)begin
  if(reset)begin track_meta<=0;track_sync<=0;en_meta<=0;en_sync<=0;selected<=0;state<=WAIT;guard<=0;phase<=0;assembly<=0;end
  else begin
   track_meta<=track;track_sync<=track_meta;en_meta<=enable;en_sync<=en_meta;
   if(state!=RUN)begin phase<=0;assembly<=0;end
   else if(accept)begin
    phase<=phase+1'b1;
    case(phase)0:assembly[7:0]<=data;1:assembly[15:8]<=data;2:assembly[23:16]<=data;endcase
   end
   case(state)
    WAIT:if(en_sync && AUDIO_BASE_LBA!=0)begin selected<=track_sync;guard<=511;state<=FLUSH;end
    FLUSH:if(guard!=0)guard<=guard-1'b1;
     else if(!en_sync || !usable)state<=WAIT;else state<=RUN;
    RUN:if(!en_sync || track_sync!=selected || card_error)state<=DRAIN;
    DRAIN:if(stopped)state<=WAIT;
   endcase
  end
 end
 SOFTFIFO #(.DATA_WIDTH_W(32),.DATA_WIDTH_R(32),.ADDR_WIDTH_W(12),.ADDR_WIDTH_R(12),.OUTREG_EN("NOREG")) fifo(
  .rst(fifo_reset),.clkw(sys_clk),.clkr(pixel_clk),.we(write_pair),.di(word),
  .wrusedw(used),.full_flag(full),.re(sample_tick && !empty),.dout(pair),.empty_flag(empty));
 reg [2:0] pixel_reset;
 always @(posedge pixel_clk or posedge fifo_reset)
  if(fifo_reset)pixel_reset<=7;else pixel_reset<={pixel_reset[1:0],1'b0};
 always @(posedge pixel_clk or posedge reset)begin
  if(reset)begin left<=0;right<=0;underruns<=0;end
  else if(pixel_reset[2])begin left<=0;right<=0;end
  else if(sample_tick)begin
   if(!empty)begin left<=pair[15:0];right<=pair[31:16];end
   else begin left<=0;right<=0;if(underruns!=32'hffffffff)underruns<=underruns+1'b1;end
  end
 end
endmodule
