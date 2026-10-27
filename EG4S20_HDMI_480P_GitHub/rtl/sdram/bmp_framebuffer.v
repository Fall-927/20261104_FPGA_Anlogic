// Single-frame RGB565 store. Pixels arrive in BMP bottom-up order and are
// written sequentially; the read pointer starts at the last row and advances
// left-to-right. Only the low half of the 32-bit physical SDRAM is used.
module bmp_framebuffer(
 input wire mem_clk,mem_clk_shift,reset,
 input wire write_clk,pixel_valid,input wire [15:0] pixel,
 input wire pixel_clk,read_enable,output wire [15:0] rgb565,
 output wire init_done,output reg loaded,output wire empty,
 output reg overflow
);
 wire [10:0] wr_used,rd_used;
 wire [15:0] din,dout;
 wire wr_ack,rd_ack;
 wire wr_full;
 reg [20:0] wr_addr,rd_addr;
 reg wr_ack_d,rd_ack_d;
 reg [9:0] row;
 reg [2:0] segment;
 reg [4:0] settle;
 wire wr_req=init_done && !loaded && wr_used>=128;
 wire rd_req=loaded && rd_used<256;
 SOFTFIFO #(.OUTREG_EN("NOREG")) wf(
 .rst(reset),.clkw(write_clk),.we(pixel_valid),.di(pixel),
 .clkr(mem_clk),.re(wr_ack),.dout(din),.rdusedw(wr_used),.full_flag(wr_full));
 SOFTFIFO #(.OUTREG_EN("NOREG")) rf(
 .rst(reset),.clkw(mem_clk),.we(rd_ack),.di(dout),.wrusedw(rd_used),
 .clkr(pixel_clk),.re(read_enable && !empty),.dout(rgb565),.empty_flag(empty));
 always @(posedge write_clk or posedge reset)
  if(reset) overflow<=0;
  else if(pixel_valid && wr_full) overflow<=1;
 always @(posedge mem_clk or posedge reset) begin
  if(reset) begin
   wr_addr<=0;rd_addr<=306560;row<=479;segment<=0;
   wr_ack_d<=0;rd_ack_d<=0;loaded<=0;settle<=0;
  end else begin
   wr_ack_d<=wr_ack;rd_ack_d<=rd_ack;
   if(wr_ack_d && !wr_ack) wr_addr<=wr_addr+128;
   // Wait for final burst's precharge before enabling video reads.
   if(wr_addr==307200 && !loaded) begin
    if(settle==31) loaded<=1;else settle<=settle+1'b1;
   end
   if(rd_ack_d && !rd_ack) begin
    if(segment==4) begin
     segment<=0;
     if(row==0) begin row<=479;rd_addr<=306560;end
     else begin row<=row-1'b1;rd_addr<=rd_addr-1152;end
    end else begin segment<=segment+1'b1;rd_addr<=rd_addr+128;end
   end
  end
 end
 wire cke,cs,ras,cas,we;
 wire [1:0] ba;
 wire [10:0] addr;
 wire [31:0] dq;
 sdram_controller ctrl(.clk(mem_clk),.rst_n(!reset),
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
