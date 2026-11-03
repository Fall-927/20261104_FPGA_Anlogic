//****************************************Copyright (c)***********************************//
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
module sdram_cmd(
    input             clk,
    input             rst_n,
    input      [20:0] sys_wraddr,
    input      [20:0] sys_rdaddr,
    input      [ 8:0] sdram_wr_burst,
    input      [ 8:0] sdram_rd_burst,
    input      [ 4:0] init_state,
    input      [ 3:0] work_state,
    input      [ 9:0] cnt_clk,
    input             sdram_rd_wr,
    output            sdram_cke,
    output            sdram_cs_n,
    output            sdram_ras_n,
    output            sdram_cas_n,
    output            sdram_we_n,
    output reg [ 1:0] sdram_ba,
    output reg [10:0] sdram_addr
    );
`include "sdram_para.v"
reg  [ 4:0] sdram_cmd_r;
wire [20:0] sys_addr;
assign {sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} = sdram_cmd_r;
assign sys_addr = sdram_rd_wr ? sys_rdaddr : sys_wraddr;
always @ (posedge clk or negedge rst_n) begin
	if(!rst_n) begin
			sdram_cmd_r <= `CMD_INIT;
			sdram_ba    <= 2'b11;
			sdram_addr  <= 11'h7ff;
	end
	else
		case(init_state)
            `I_NOP,`I_TRP,`I_TRF,`I_TRSC: begin
                    sdram_cmd_r <= `CMD_NOP;
                    sdram_ba    <= 2'b11;
                    sdram_addr  <= 11'h7ff;
                end
            `I_PRE: begin
                    sdram_cmd_r <= `CMD_PRGE;
                    sdram_ba    <= 2'b11;
                    sdram_addr  <= 11'h7ff;
                end
            `I_AR: begin
                    sdram_cmd_r <= `CMD_A_REF;
                    sdram_ba    <= 2'b11;
                    sdram_addr  <= 11'h7ff;
                end
            `I_MRS: begin
                    sdram_cmd_r <= `CMD_LMR;
                    sdram_ba    <= 2'b00;
                    sdram_addr  <= {
                        1'b0,
                        1'b0,
                        2'b00,
                        3'b011,
                        1'b0,
                        3'b111
					};
                end
            `I_DONE:
					case(work_state)
                        `W_IDLE,`W_TRCD,`W_CL,`W_TWR,`W_TRP,`W_TRFC: begin
                                sdram_cmd_r <= `CMD_NOP;
                                sdram_ba    <= 2'b11;
                                sdram_addr  <= 11'h7ff;
                            end
                        `W_ACTIVE: begin
                                sdram_cmd_r <= `CMD_ACTIVE;
                                sdram_ba    <= sys_addr[20:19];
                                sdram_addr  <= sys_addr[18:8];
                            end
                        `W_READ: begin
                                sdram_cmd_r <= `CMD_READ;
                                sdram_ba    <= sys_addr[20:19];
                                sdram_addr  <= {3'b000,sys_addr[7:0]};
                            end
                        `W_RD: begin
                                if(`end_rdburst)
                                    sdram_cmd_r <= `CMD_B_STOP;
                                else begin
                                    sdram_cmd_r <= `CMD_NOP;
                                    sdram_ba    <= 2'b11;
                                    sdram_addr  <= 11'h7ff;
                                end
                            end
                        `W_WRITE: begin
                                sdram_cmd_r <= `CMD_WRITE;
                                sdram_ba    <= sys_addr[20:19];
                                sdram_addr  <= {3'b000,sys_addr[7:0]};
                            end
                        `W_WD: begin
                                if(`end_wrburst)
                                    sdram_cmd_r <= `CMD_B_STOP;
                                else begin
                                    sdram_cmd_r <= `CMD_NOP;
                                    sdram_ba    <= 2'b11;
                                    sdram_addr  <= 11'h7ff;
                                end
                            end
                        `W_PRE:begin
                                sdram_cmd_r <= `CMD_PRGE;
                                sdram_ba    <= sys_addr[20:19];
                                sdram_addr  <= 11'h000;
                            end
                        `W_AR: begin
                                sdram_cmd_r <= `CMD_A_REF;
                                sdram_ba    <= 2'b11;
                                sdram_addr  <= 11'h7ff;
                            end
                        default: begin
                                sdram_cmd_r <= `CMD_NOP;
                                sdram_ba    <= 2'b11;
                                sdram_addr  <= 11'h7ff;
                            end
					endcase
            default: begin
                    sdram_cmd_r <= `CMD_NOP;
                    sdram_ba    <= 2'b11;
                    sdram_addr  <= 11'h7ff;
                end
		endcase
end
endmodule
