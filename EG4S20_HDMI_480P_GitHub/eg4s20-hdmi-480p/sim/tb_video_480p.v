`timescale 1ns/1ps
module tb_video_480p;
    reg clk = 0;
    always #19.841269841 clk = ~clk;
    reg reset = 1;
    wire hs, vs, de;
    wire [7:0] r,g,b;
    integer x,y,frame,active_count,hs_count,vs_count;
    reg [23:0] expected;
    video_480p_bars dut(.clk(clk),.reset(reset),.hsync(hs),.vsync(vs),
        .de(de),.red(r),.green(g),.blue(b));
    initial begin
        #100000000; $fatal(1,"Watchdog timeout");
    end
    initial begin
        repeat (4) @(negedge clk);
        if (de !== 0) $fatal(1,"DE during reset");
        reset=0;
        for (frame=0;frame<2;frame=frame+1) begin
            active_count=0; hs_count=0; vs_count=0;
            for (y=0;y<525;y=y+1) begin
                for (x=0;x<800;x=x+1) begin
                    #1;
                    if (de !== (x<640 && y<480)) $fatal(1,"DE mismatch");
                    if (hs !== !(x>=656 && x<752)) $fatal(1,"HS mismatch");
                    if (vs !== !(y>=490 && y<492)) $fatal(1,"VS mismatch");
                    if (de) active_count=active_count+1;
                    if (!hs) hs_count=hs_count+1;
                    if (!vs) vs_count=vs_count+1;
                    expected=0;
                    if (de) case (x/80)
                        0:expected=24'hffffff; 1:expected=24'hffff00;
                        2:expected=24'h00ffff; 3:expected=24'h00ff00;
                        4:expected=24'hff00ff; 5:expected=24'hff0000;
                        6:expected=24'h0000ff; 7:expected=24'h000000;
                        default: $fatal(1,"Invalid color bar");
                    endcase
                    if ({r,g,b} !== expected) $fatal(1,"Color mismatch");
                    @(negedge clk);
                end
            end
            if (active_count!=307200 || hs_count!=50400 || vs_count!=1600)
                $fatal(1,"Frame totals mismatch");
        end
        repeat (17) @(negedge clk);
        #3; reset=1; #1;
        if (de !== 0 || dut.x !== 0 || dut.y !== 0) $fatal(1,"Async reset");
        $display("PASS: two 640x480 frames, 800x525 total, negative HS/VS, eight 80-pixel bars, reset");
        $finish;
    end
endmodule
