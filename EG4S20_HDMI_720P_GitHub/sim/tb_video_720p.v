`timescale 1ns/1ps
module tb_video_720p;
    reg clk = 0;
    always #6.7340067 clk = ~clk;
    reg reset = 1;
    wire hs, vs, de;
    wire [7:0] r,g,b;
    integer x,y,active_count,hs_count,vs_count;
    reg [23:0] expected;
    video_720p_bars dut(.clk(clk),.reset(reset),.hsync(hs),.vsync(vs),
        .de(de),.red(r),.green(g),.blue(b));
    initial begin
        active_count=0; hs_count=0; vs_count=0;
        repeat (4) @(negedge clk);
        reset=0;
        for (y=0;y<750;y=y+1) begin
            for (x=0;x<1650;x=x+1) begin
                #1;
                if (de !== (x<1280 && y<720)) $fatal(1,"DE mismatch");
                if (hs !== (x>=1390 && x<1430)) $fatal(1,"HS mismatch");
                if (vs !== (y>=725 && y<730)) $fatal(1,"VS mismatch");
                if (de) active_count=active_count+1;
                if (hs) hs_count=hs_count+1;
                if (vs) vs_count=vs_count+1;
                expected=0;
                if (de) case (x/160)
                    0:expected=24'hffffff; 1:expected=24'hffff00;
                    2:expected=24'h00ffff; 3:expected=24'h00ff00;
                    4:expected=24'hff00ff; 5:expected=24'hff0000;
                    6:expected=24'h0000ff; 7:expected=24'h000000;
                endcase
                if ({r,g,b} !== expected) $fatal(1,"Color mismatch");
                @(negedge clk);
            end
        end
        if (active_count!=921600 || hs_count!=30000 || vs_count!=8250)
            $fatal(1,"Frame totals mismatch");
        $display("PASS: 1280x720 active, 1650x750 total, eight color bars");
        $finish;
    end
endmodule
