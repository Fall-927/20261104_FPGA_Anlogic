module sdram_data #(parameter DATA_WIDTH=16)(
    input             lane_high,
    input             clk,
    input             rst_n,
    input   [15:0]    sdram_data_in,
    output  [15:0]    sdram_data_out,
    input   [ 3:0]    work_state,
    input   [ 9:0]    cnt_clk,
    inout   [DATA_WIDTH-1:0] sdram_data
    );
`include "sdram_para.v"
reg        sdram_out_en;
reg [15:0] sdram_din_r;
reg [15:0] sdram_dout_r;
assign sdram_data = sdram_out_en ? {(DATA_WIDTH/16){sdram_din_r}} : {DATA_WIDTH{1'bz}};
wire [15:0] selected_data;
generate if(DATA_WIDTH==32) begin: full_bus
 assign selected_data=lane_high ? sdram_data[31:16]:sdram_data[15:0];
end else begin: half_bus
 assign selected_data=sdram_data[15:0];
end endgenerate
assign sdram_data_out = sdram_dout_r;
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n)
       sdram_out_en <= 1'b0;
   else if((work_state == `W_WRITE) | (work_state == `W_WD))
       sdram_out_en <= 1'b1;
   else
       sdram_out_en <= 1'b0;
end
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n)
        sdram_din_r <= 16'd0;
	else if((work_state == `W_WRITE) | (work_state == `W_WD))
        sdram_din_r <= sdram_data_in;
end
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n)
        sdram_dout_r <= 16'd0;
	else if(work_state == `W_RD)
        sdram_dout_r <= selected_data;
end
endmodule
