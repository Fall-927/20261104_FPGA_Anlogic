module dip_switches #(parameter STABLE_CYCLES=504000)(
 input clk,reset,input [7:0] raw,output reg [7:0] stable
);
 (* ASYNC_REG="TRUE" *) reg [7:0] meta,sync;
 reg [19:0] count[0:7];integer i;
 always @(posedge clk or posedge reset)begin
  if(reset)begin meta<=0;sync<=0;stable<=0;for(i=0;i<8;i=i+1)count[i]<=0;end
  else begin
   meta<=raw;sync<=meta;
   for(i=0;i<8;i=i+1)begin
    if(sync[i]==stable[i])count[i]<=0;
    else if(count[i]==STABLE_CYCLES-1)begin stable[i]<=sync[i];count[i]<=0;end
    else count[i]<=count[i]+1'b1;
   end
  end
 end
endmodule
