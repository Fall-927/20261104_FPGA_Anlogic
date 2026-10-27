// Test-only transaction model; does not simulate SDRAM electrical timing.
module sdram_controller(
 input clk,rst_n,sdram_wr_req,sdram_rd_req,
 input [20:0] sdram_wr_addr,sdram_rd_addr,
 input [8:0] sdram_wr_burst,sdram_rd_burst,input [15:0] sdram_din,
 output reg [15:0] sdram_dout,output sdram_wr_ack,output reg sdram_rd_ack,
 output sdram_init_done,idle,sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n,
 output [1:0] sdram_ba,output [10:0] sdram_addr,inout [15:0] sdram_data
);
 reg [15:0] memory[0:921599];
 reg [20:0] address;
 reg [7:0] count;
 reg [3:0] cooldown;
 reg active,reading;
 reg write_pending;
 reg [20:0] write_address;
 assign idle=!active && cooldown==0;
 assign sdram_init_done=rst_n;
 assign sdram_wr_ack=active && !reading;
 assign {sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n,sdram_ba,sdram_addr}=0;
 assign sdram_data=16'bz;
 always @(posedge clk or negedge rst_n) begin
  // Match the real controller's early FIFO request and registered write data.
  if(!rst_n) begin write_pending<=0;write_address<=0;end
  else begin
   write_pending<=active && !reading;
   write_address<=address;
   if(write_pending) memory[write_address]<=sdram_din;
  end
 end
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin sdram_dout<=0;sdram_rd_ack<=0;end
  else begin sdram_rd_ack<=active && reading;if(active && reading) sdram_dout<=memory[address];end
 end
 always @(posedge clk or negedge rst_n) begin
  if(!rst_n) begin active<=0;reading<=0;count<=0;cooldown<=0;address<=0;end
  else if(active) begin
   address<=address+1'b1;
   if(count==127) begin active<=0;cooldown<=8;end
   else count<=count+1'b1;
  end else if(cooldown!=0) cooldown<=cooldown-1'b1;
  else if(sdram_wr_req || sdram_rd_req) begin
   active<=1;reading<=!sdram_wr_req;count<=0;
   address<=sdram_wr_req ? sdram_wr_addr:sdram_rd_addr;
  end
 end
endmodule
module SDRAM(input clk,ras_n,cas_n,we_n,input [10:0] addr,
 input [1:0] ba,inout [31:0] dq,input cs_n,dm0,dm1,dm2,dm3,cke);
 assign dq=32'bz;
endmodule
