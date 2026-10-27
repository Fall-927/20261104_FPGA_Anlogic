`timescale 1ns/1ps
module tmds_serializer_eg4 (
    input wire clk_5x, input wire reset, input wire pixel_toggle,
    input wire [9:0] symbol_b, input wire [9:0] symbol_g, input wire [9:0] symbol_r,
    output wire [2:0] serial_data, output wire serial_clock
);
    // Bundled-data transfer requires phase-related clocks with a 5:1 ratio.
    reg [2:0] toggle_pipe;
    wire load_symbol = toggle_pipe[2] ^ toggle_pipe[1];
    reg [9:0] shift_b, shift_g, shift_r, shift_c;
    reg [1:0] pair_b, pair_g, pair_r, pair_c;
    always @(posedge clk_5x or posedge reset) begin
        if (reset) begin
            toggle_pipe <= 0;
            shift_b <= 0; shift_g <= 0; shift_r <= 0; shift_c <= 0;
            pair_b <= 0; pair_g <= 0; pair_r <= 0; pair_c <= 0;
        end else begin
            toggle_pipe <= {toggle_pipe[1:0], pixel_toggle};
            if (load_symbol) begin
                pair_b <= symbol_b[1:0]; shift_b <= {2'b00, symbol_b[9:2]};
                pair_g <= symbol_g[1:0]; shift_g <= {2'b00, symbol_g[9:2]};
                pair_r <= symbol_r[1:0]; shift_r <= {2'b00, symbol_r[9:2]};
                // TMDS clock pattern, LSB first.
                pair_c <= 2'b00; shift_c <= {2'b00, 8'b11111000};
            end else begin
                pair_b <= shift_b[1:0]; shift_b <= {2'b00, shift_b[9:2]};
                pair_g <= shift_g[1:0]; shift_g <= {2'b00, shift_g[9:2]};
                pair_r <= shift_r[1:0]; shift_r <= {2'b00, shift_r[9:2]};
                pair_c <= shift_c[1:0]; shift_c <= {2'b00, shift_c[9:2]};
            end
        end
    end
    EG_LOGIC_ODDR #(.ASYNCRST("ENABLE")) u_b
        (.clk(clk_5x), .rst(reset), .d0(pair_b[0]), .d1(pair_b[1]), .q(serial_data[0]));
    EG_LOGIC_ODDR #(.ASYNCRST("ENABLE")) u_g
        (.clk(clk_5x), .rst(reset), .d0(pair_g[0]), .d1(pair_g[1]), .q(serial_data[1]));
    EG_LOGIC_ODDR #(.ASYNCRST("ENABLE")) u_r
        (.clk(clk_5x), .rst(reset), .d0(pair_r[0]), .d1(pair_r[1]), .q(serial_data[2]));
    EG_LOGIC_ODDR #(.ASYNCRST("ENABLE")) u_c
        (.clk(clk_5x), .rst(reset), .d0(pair_c[0]), .d1(pair_c[1]), .q(serial_clock));
endmodule
