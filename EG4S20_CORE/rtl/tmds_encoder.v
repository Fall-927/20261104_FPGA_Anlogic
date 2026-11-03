`timescale 1ns/1ps
module tmds_encoder (
    input wire clk, input wire reset, input wire de,
    input wire c0, input wire c1, input wire [7:0] data,
    output reg [9:0] symbol
);
    integer i;
    reg [3:0] ones_data, ones_q;
    reg signed [5:0] balance;
    reg [8:0] q_m;
    reg use_xnor;
    reg [9:0] next_symbol;
    reg signed [5:0] disparity, next_disparity;
    always @* begin
        ones_data = 0;
        for (i = 0; i < 8; i = i + 1) ones_data = ones_data + {3'b000,data[i]};
        use_xnor = (ones_data > 4) || ((ones_data == 4) && !data[0]);
        q_m[0] = data[0];
        for (i = 1; i < 8; i = i + 1)
            q_m[i] = use_xnor ? ~(q_m[i-1] ^ data[i]) : (q_m[i-1] ^ data[i]);
        q_m[8] = !use_xnor;
        ones_q = 0;
        for (i = 0; i < 8; i = i + 1) ones_q = ones_q + {3'b000,q_m[i]};
        balance = $signed({1'b0,ones_q,1'b0}) - 6'sd8;
        next_symbol = 10'b1101010100;
        next_disparity = 0;
        if (!de) begin
            case ({c1,c0})
                2'b00: next_symbol = 10'b1101010100;
                2'b01: next_symbol = 10'b0010101011;
                2'b10: next_symbol = 10'b0101010100;
                2'b11: next_symbol = 10'b1010101011;
            endcase
        end else if ((disparity == 0) || (balance == 0)) begin
            next_symbol = {~q_m[8], q_m[8], q_m[8] ? q_m[7:0] : ~q_m[7:0]};
            next_disparity = disparity + (q_m[8] ? balance : -balance);
        end else if (((disparity > 0) && (balance > 0)) ||
                     ((disparity < 0) && (balance < 0))) begin
            next_symbol = {1'b1, q_m[8], ~q_m[7:0]};
            next_disparity = disparity - balance + (q_m[8] ? 6'sd2 : 6'sd0);
        end else begin
            next_symbol = {1'b0, q_m[8], q_m[7:0]};
            next_disparity = disparity + balance - (q_m[8] ? 6'sd0 : 6'sd2);
        end
    end
    always @(posedge clk or posedge reset) begin
        if (reset) begin symbol <= 10'b1101010100; disparity <= 0; end
        else begin symbol <= next_symbol; disparity <= next_disparity; end
    end
endmodule
