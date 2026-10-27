module sd_spi_clock #(parameter DIV=63)(input wire clk,input wire reset,output reg spi_clk,output reg tick);
    reg [7:0] count;
    always @(posedge clk or posedge reset) begin
        if(reset) begin count<=0; spi_clk<=0; tick<=0; end
        else if(count==DIV-1) begin count<=0; spi_clk<=~spi_clk; tick<=1; end
        else begin count<=count+1'b1; tick<=0; end
    end
endmodule
