// Unsigned restoring divider. Start only when !busy, result after 32 clocks.
module scale_divider(
 input clk,reset,start,input [31:0] numerator,denominator,
 output reg busy,done,output reg [31:0] quotient
);
 reg [31:0] dividend,divisor;
 reg [32:0] remainder;
 reg [5:0] count;
 wire [32:0] shifted={remainder[31:0],dividend[31]};
 always @(posedge clk or posedge reset)
  if(reset) begin busy<=0;done<=0;quotient<=0;dividend<=0;divisor<=0;remainder<=0;count<=0;end
  else begin
   done<=0;
   if(start && !busy) begin
    dividend<=numerator;divisor<=denominator;remainder<=0;quotient<=0;count<=0;busy<=1;
   end else if(busy) begin
    dividend<={dividend[30:0],1'b0};
    if(shifted>={1'b0,divisor}) begin
     remainder<=shifted-{1'b0,divisor};quotient<={quotient[30:0],1'b1};
    end else begin remainder<=shifted;quotient<={quotient[30:0],1'b0};end
    if(count==31) begin busy<=0;done<=1;end else count<=count+1'b1;
   end
  end
endmodule
