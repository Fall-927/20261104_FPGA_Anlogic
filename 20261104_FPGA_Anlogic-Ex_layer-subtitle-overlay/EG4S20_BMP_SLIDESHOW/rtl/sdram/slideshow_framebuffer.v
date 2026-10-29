// Preload three complete BMP frames once, then serve an immutable playlist.
// At each vertical blank: stop requests, finish any outstanding burst, clear
// stale read-ahead data, select a frame, then refill well before active video.
module slideshow_framebuffer(
 input wire mem_clk,mem_clk_shift,reset,
 input wire write_clk,pixel_valid,input wire [15:0] pixel,
 input wire pixel_clk,read_enable,frame_toggle,input wire [1:0] image_index,
 output wire [15:0] rgb565,output wire empty,init_done,
 output reg loaded,output reg overflow
);
 wire [10:0] wr_used,rd_used;
 wire [15:0] din,dout;
 wire wr_ack,rd_ack,wr_full,idle;
 reg [20:0] wr_addr,rd_addr,base;
 reg wr_ack_d,rd_ack_d;
 reg [9:0] row;
 reg [2:0] segment;
 reg [18:0] read_words;
 reg [5:0] settle;
 reg [2:0] frame_sync;
 reg frame_seen;
 reg [1:0] index_meta,index_sync;
 reg [1:0] phase;
 reg [5:0] clear_count;
 wire fifo_clear=reset || phase==2;
 wire wr_req=init_done && !loaded && wr_used>=128;
 wire rd_req=loaded && phase==0 && read_words<307200 && rd_used<256;
 function [20:0] frame_base;
  input [1:0] i;
  begin case(i) 1:frame_base=307200;2:frame_base=614400;default:frame_base=0;endcase end
 endfunction
 // The reference controller asserts wr_ack one cycle ahead of data capture.
 // Keep the FIFO output register: NOREG advances to pixel 1 before WRITE,
 // skipping the first pixel and substituting an invalid tail at each burst.
 SOFTFIFO #(.OUTREG_EN("OUTREG")) wf(
 .rst(reset),.clkw(write_clk),.we(pixel_valid),.di(pixel),
 .clkr(mem_clk),.re(wr_ack),.dout(din),.rdusedw(wr_used),.full_flag(wr_full));
 SOFTFIFO #(.OUTREG_EN("NOREG")) rf(
 .rst(fifo_clear),.clkw(mem_clk),.we(rd_ack && phase==0),.di(dout),
 .wrusedw(rd_used),.clkr(pixel_clk),.re(read_enable && !empty),
 .dout(rgb565),.empty_flag(empty));
 always @(posedge write_clk or posedge reset)
  if(reset) overflow<=0;else if(pixel_valid && wr_full) overflow<=1;
 always @(posedge mem_clk or posedge reset) begin
  if(reset) begin
   wr_addr<=0;rd_addr<=306560;base<=0;row<=479;segment<=0;
   wr_ack_d<=0;rd_ack_d<=0;loaded<=0;settle<=0;
   frame_sync<=0;frame_seen<=0;index_meta<=0;index_sync<=0;
   phase<=3;clear_count<=0;read_words<=307200;
  end else begin
   frame_sync<={frame_sync[1:0],frame_toggle};
   index_meta<=image_index;index_sync<=index_meta;
   wr_ack_d<=wr_ack;rd_ack_d<=rd_ack;
   if(wr_ack_d && !wr_ack) wr_addr<=wr_addr+128;
   if(wr_addr==921600 && !loaded) begin
    if(settle==63) loaded<=1;else settle<=settle+1'b1;
   end
   if(frame_sync[2]!=frame_seen && loaded) begin
    frame_seen<=frame_sync[2];phase<=1;base<=frame_base(index_sync);
   end
   if(phase==1 && idle && !rd_ack && !rd_ack_d) begin
    phase<=2;clear_count<=0;
    rd_addr<=base+306560;row<=479;segment<=0;read_words<=0;
   end
   if(phase==2) begin
    if(clear_count==31) phase<=0;else clear_count<=clear_count+1'b1;
   end
   if(phase==0 && rd_ack_d && !rd_ack) begin
    read_words<=read_words+128;
    if(segment==4) begin
     segment<=0;
     if(row!=0) begin row<=row-1'b1;rd_addr<=rd_addr-1152;end
    end else begin segment<=segment+1'b1;rd_addr<=rd_addr+128;end
   end
  end
 end
 wire cke,cs,ras,cas,we;
 wire [1:0] ba;
 wire [10:0] addr;
 wire [31:0] dq;
 // idle is exported by the reference controller for safe FIFO flushing.
 sdram_controller ctrl(.clk(mem_clk),.rst_n(!reset),.idle(idle),
 .sdram_wr_req(wr_req),.sdram_wr_ack(wr_ack),.sdram_wr_addr(wr_addr),
 .sdram_wr_burst(9'd128),.sdram_din(din),
 .sdram_rd_req(rd_req),.sdram_rd_ack(rd_ack),.sdram_rd_addr(rd_addr),
 .sdram_rd_burst(9'd128),.sdram_dout(dout),.sdram_init_done(init_done),
 .sdram_cke(cke),.sdram_cs_n(cs),.sdram_ras_n(ras),.sdram_cas_n(cas),
 .sdram_we_n(we),.sdram_ba(ba),.sdram_addr(addr),.sdram_data(dq[15:0]));
 SDRAM physical(.clk(mem_clk_shift),.ras_n(ras),.cas_n(cas),.we_n(we),
 .addr(addr),.ba(ba),.dq(dq),.cs_n(cs),.dm0(1'b0),.dm1(1'b0),
 .dm2(1'b1),.dm3(1'b1),.cke(cke));
endmodule
