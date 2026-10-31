// Exercise the actual reference command/data controller, not a transaction stub.
module sdram_write_path_tb(
 input clk,reset,pixel_valid,input [15:0] pixel,
 output init_done,output [15:0] bus_data,output [4:0] command,
 output [10:0] address,output [1:0] bank,output [20:0] write_address
);
 wire [10:0] used;
 wire [15:0] din;
 wire ack;
 reg ack_d;
 reg [20:0] wr_addr;
 wire [15:0] dq;
 SOFTFIFO #(.OUTREG_EN("OUTREG")) wf(.rst(reset),.clkw(clk),.we(pixel_valid),
 .di(pixel),.clkr(clk),.re(ack),.dout(din),.rdusedw(used));
 always @(posedge clk or posedge reset)
  if(reset)begin ack_d<=0;wr_addr<=0;end
  else begin ack_d<=ack;if(ack_d && !ack)wr_addr<=wr_addr+128;end
 assign write_address=wr_addr;
 assign bus_data=dq;
 sdram_controller ctrl(.clk(clk),.rst_n(!reset),
 .sdram_wr_req(init_done && used>=128),.sdram_wr_ack(ack),.sdram_wr_addr(wr_addr),
 .sdram_wr_burst(9'd128),.sdram_din(din),.sdram_rd_req(1'b0),
 .sdram_rd_addr(21'd0),.sdram_rd_burst(9'd128),.sdram_init_done(init_done),
 .sdram_cke(command[4]),.sdram_cs_n(command[3]),.sdram_ras_n(command[2]),
 .sdram_cas_n(command[1]),.sdram_we_n(command[0]),.sdram_ba(bank),
 .sdram_addr(address),.sdram_data(dq));
endmodule
