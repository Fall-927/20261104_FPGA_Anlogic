module sdram_controller #(parameter ADDR_WIDTH=21, DATA_WIDTH=16)(
    output wire lane_high,
    output wire idle,
    input         clk,
    input         rst_n,
    input         sdram_wr_req,
    output        sdram_wr_ack,
    input  [ADDR_WIDTH-1:0] sdram_wr_addr,
    input  [ 8:0] sdram_wr_burst,
    input  [15:0] sdram_din,
    input         sdram_rd_req,
    output        sdram_rd_ack,
    input  [ADDR_WIDTH-1:0] sdram_rd_addr,
    input  [ 8:0] sdram_rd_burst,
    output [15:0] sdram_dout,
    output	      sdram_init_done,
    output        sdram_cke,
    output        sdram_cs_n,
    output        sdram_ras_n,
    output        sdram_cas_n,
    output        sdram_we_n,
    output [ 1:0] sdram_ba,
    output [10:0] sdram_addr,
    inout  [DATA_WIDTH-1:0] sdram_data
    );
wire [4:0] init_state;
wire [3:0] work_state;
wire [9:0] cnt_clk;
wire       sdram_rd_wr;
assign idle = sdram_init_done && (work_state == 4'd0);
generate if(ADDR_WIDTH==22) begin: extended_lane
 reg lane;
 always @(posedge clk or negedge rst_n)
  if(!rst_n) lane<=0;
  else if(idle && (sdram_wr_req || sdram_rd_req))
   lane<=sdram_wr_req ? sdram_wr_addr[21]:sdram_rd_addr[21];
 assign lane_high=lane;
end else begin: lower_lane
 assign lane_high=1'b0;
end endgenerate
sdram_ctrl u_sdram_ctrl(
    .clk                (clk),
    .rst_n              (rst_n),
    .sdram_wr_req       (sdram_wr_req),
    .sdram_rd_req       (sdram_rd_req),
    .sdram_wr_ack       (sdram_wr_ack),
    .sdram_rd_ack       (sdram_rd_ack),
    .sdram_wr_burst     (sdram_wr_burst),
    .sdram_rd_burst     (sdram_rd_burst),
    .sdram_init_done    (sdram_init_done),
    .init_state         (init_state),
    .work_state         (work_state),
    .cnt_clk            (cnt_clk),
    .sdram_rd_wr        (sdram_rd_wr)
    );
sdram_cmd u_sdram_cmd(
    .clk                (clk),
    .rst_n              (rst_n),
    .sys_wraddr         (sdram_wr_addr[20:0]),
    .sys_rdaddr         (sdram_rd_addr[20:0]),
    .sdram_wr_burst     (sdram_wr_burst),
    .sdram_rd_burst     (sdram_rd_burst),
    .init_state         (init_state),
    .work_state         (work_state),
    .cnt_clk            (cnt_clk),
    .sdram_rd_wr        (sdram_rd_wr),
    .sdram_cke          (sdram_cke),
    .sdram_cs_n         (sdram_cs_n),
    .sdram_ras_n        (sdram_ras_n),
    .sdram_cas_n        (sdram_cas_n),
    .sdram_we_n         (sdram_we_n),
    .sdram_ba           (sdram_ba),
    .sdram_addr         (sdram_addr)
    );
sdram_data #(.DATA_WIDTH(DATA_WIDTH)) u_sdram_data(
    .lane_high          (lane_high),
    .clk                (clk),
    .rst_n              (rst_n),
    .sdram_data_in      (sdram_din),
    .sdram_data_out     (sdram_dout),
    .work_state         (work_state),
    .cnt_clk            (cnt_clk),
    .sdram_data         (sdram_data)
    );
endmodule
