`timescale 1ns/1ps
module tb_pll_480p;
    reg refclk=0, reset=1;
    always #10 refclk=~refclk;
    wire pixel_clk,serial_clk,locked;
    realtime p0,p1,s0,s1;
    hdmi_pll_480p dut(.refclk(refclk),.reset(reset),.pixel_clk(pixel_clk),
        .serial_clk(serial_clk),.locked(locked));
    initial begin #1000000; $fatal(1,"PLL lock timeout"); end
    initial begin
        #200; reset=0;
        wait(locked===1);
        repeat(10) @(posedge pixel_clk);
        @(posedge pixel_clk); p0=$realtime;
        repeat(100) @(posedge pixel_clk); p1=$realtime;
        @(posedge serial_clk); s0=$realtime;
        repeat(500) @(posedge serial_clk); s1=$realtime;
        $display("Measured intervals: pixel=%0.6f ns serial=%0.6f ns",p1-p0,s1-s0);
        // Vendor model uses quantized internal time steps; allow 0.1% error.
        if ((p1-p0<3964.0)||(p1-p0>3972.0)) $fatal(1,"Pixel frequency");
        if ((s1-s0<3964.0)||(s1-s0>3972.0)) $fatal(1,"Serial frequency");
        $display("PASS: vendor PLL model locks; pixel period=%0.6f ns, serial period=%0.6f ns",(p1-p0)/100,(s1-s0)/500);
        $finish;
    end
endmodule
