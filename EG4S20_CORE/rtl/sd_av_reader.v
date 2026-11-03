module sd_av_reader #(parameter FAST_DIV=0,LOOP=1,SAFE_STOP=0,LOOP_SKIP=1)(
 input wire [31:0] start_lba,sector_count,
 input wire clk,reset,sd_miso,data_ready,
 output reg sd_cs,output wire sd_sck,sd_mosi,
 output reg [7:0] data_byte,output reg data_valid,done,error,
 input wire stop_request,output reg stopped
);
 reg [7:0] tx;wire [7:0] rx;
 reg launch,slow;wire byte_busy,byte_done;
 spi_byte_master #(.FAST_DIV(FAST_DIV)) spi(.clk(clk),.reset(reset),.start(launch),.tx(tx),.slow(slow),
  .miso(sd_miso),.sck(sd_sck),.mosi(sd_mosi),.rx(rx),.busy(byte_busy),.done(byte_done));
 reg [4:0] state,after_byte;
 reg [47:0] command;reg [2:0] cmd_byte,extra,op;
 reg [7:0] response;reg [15:0] tries;reg [19:0] timeout;
 reg [9:0] count;reg [31:0] blocks,power_wait,tail,sector;
 localparam POWER=0,CLOCKS=1,PRE=2,SEND=3,R1=4,EXTRA=5,CHECK=6,
 TOKEN=7,DATA=8,CRC=9,GAP=10,WAITBYTE=11,FINISH=12,FAIL=13,SELECT=14,
 HOLD=15,FETCH=16,STOPPED=17;
 wire stopping=SAFE_STOP && stop_request;
 task transfer;
  input [7:0] value;input [4:0] next_state;
  begin tx<=value;launch<=1;after_byte<=next_state;state<=WAITBYTE;end
 endtask
 task issue;
  input [47:0] value;input [2:0] operation;
  begin command<=value;cmd_byte<=0;op<=operation;state<=PRE;sd_cs<=1;timeout<=0;end
 endtask
 always @(posedge clk or posedge reset) begin
  if(reset) begin
   sd_cs<=1;sector<=0;data_byte<=0;data_valid<=0;done<=0;error<=0;
   launch<=0;slow<=1;tx<=255;state<=POWER;after_byte<=0;command<=0;cmd_byte<=0;stopped<=0;
   extra<=0;response<=255;tries<=0;timeout<=0;count<=0;blocks<=0;power_wait<=0;tail<=0;op<=0;
  end else begin
   launch<=0;data_valid<=0;
   case(state)
    POWER: if(power_wait==50000) begin sector<=start_lba;count<=0;state<=CLOCKS;end
           else power_wait<=power_wait+1'b1;
    CLOCKS: if(count==10) issue(48'h400000000095,0);
            else begin count<=count+1'b1;transfer(255,CLOCKS);end
    PRE: begin sd_cs<=1;transfer(255,SELECT);end
    SELECT: begin sd_cs<=0;transfer(255,SEND);end
    SEND: if(cmd_byte==6) begin timeout<=0;transfer(255,R1);end
          else begin cmd_byte<=cmd_byte+1'b1;command<={command[39:0],8'hff};transfer(command[47:40],SEND);end
    WAITBYTE: if(byte_done) state<=after_byte;
    R1: if(!rx[7]) begin response<=rx;extra<=0;tail<=0;
         if(op==1 || op==4) transfer(255,EXTRA);else state<=CHECK;
        end else if(timeout==255) state<=FAIL;
        else begin timeout<=timeout+1'b1;transfer(255,R1);end
    EXTRA: begin tail<={tail[23:0],rx};
     if(extra==3) state<=CHECK;
     else begin extra<=extra+1'b1;transfer(255,EXTRA);end
    end
    CHECK: begin sd_cs<=1;
     case(op)
      0: if(response==1) issue(48'h48000001aa87,1);else state<=FAIL;
      1: if(response==1 && tail==32'h1aa) issue(48'h770000000001,2);else state<=FAIL;
      2: if(response==1 || response==0) issue(48'h694000000001,3);else state<=FAIL;
      3: if(response==0) issue(48'h7a0000000001,4);
         else if(response!=1 || tries==2000) state<=FAIL;
         else begin tries<=tries+1'b1;issue(48'h770000000001,2);end
      4: if(response==0 && tail[31:30]==2'b11) begin slow<=0;issue({8'h51,sector,8'h01},5);end else state<=FAIL;
      5: if(response==0) begin sd_cs<=0;timeout<=0;transfer(255,TOKEN);end else state<=FAIL;
      default: state<=FAIL;
     endcase
    end
    TOKEN: if(rx==8'hfe) begin count<=0;state<=FETCH;end
           else if(rx!=255 || timeout==20'hfffff) state<=FAIL;
           else begin timeout<=timeout+1'b1;transfer(255,TOKEN);end
    FETCH: if(data_ready || stopping) transfer(255,DATA);
    DATA: state<=HOLD;
    HOLD: if(data_ready || stopping) begin
     data_byte<=rx;data_valid<=!stopping;
     if(count==511) begin count<=0;transfer(255,CRC);end
     else begin count<=count+1'b1;state<=FETCH;end
    end
    CRC: if(count==0) begin count<=1;transfer(255,CRC);end else begin sd_cs<=1;transfer(255,GAP);end
    GAP: if(stopping) begin stopped<=1;state<=STOPPED;end
         else if(blocks==sector_count-1) begin
          if(LOOP) begin
           blocks<=LOOP_SKIP;sector<=start_lba+LOOP_SKIP;
           issue({8'h51,start_lba+LOOP_SKIP,8'h01},5);
          end else state<=FINISH;
         end
         else begin blocks<=blocks+1'b1;sector<=sector+1'b1;issue({8'h51,sector+32'd1,8'h01},5);end
    FINISH: begin done<=1;sd_cs<=1;if(stopping) stopped<=1;end
    STOPPED: begin stopped<=1;sd_cs<=1;end
    default: begin error<=1;sd_cs<=1;state<=FAIL;if(stopping) stopped<=1;end
   endcase
  end
 end
endmodule
