// SPI mode 0: set MOSI at falling edges, sample MISO at rising edges.
module spi_byte_master(
 input wire clk,reset,start,input wire [7:0] tx,input wire slow,
 input wire miso,output reg sck,mosi,output reg [7:0] rx,output reg busy,done
);
 reg [7:0] shift;
 reg [6:0] divider;
 reg [2:0] bitnum;
 wire [6:0] limit=slow ? 7'd62 : 7'd1;
 always @(posedge clk or posedge reset) begin
  if(reset) begin sck<=0;mosi<=1;rx<=0;busy<=0;done<=0;shift<=0;divider<=0;bitnum<=0;end
  else begin
   done<=0;
   if(!busy) begin
    sck<=0;
    if(start) begin busy<=1;shift<=tx;mosi<=tx[7];divider<=0;bitnum<=0;end
   end else if(divider==limit) begin
    divider<=0;sck<=~sck;
    if(!sck) rx<={rx[6:0],miso};
    else if(bitnum==7) begin busy<=0;done<=1;mosi<=1;end
    else begin bitnum<=bitnum+1'b1;shift<={shift[6:0],1'b1};mosi<=shift[6];end
   end else divider<=divider+1'b1;
  end
 end
endmodule
