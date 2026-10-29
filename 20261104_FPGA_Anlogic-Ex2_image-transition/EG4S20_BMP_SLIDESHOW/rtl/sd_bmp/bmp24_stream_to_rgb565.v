// Hardware BMP parser: accepts positive-height 640x480, 24-bit BGR, BI_RGB
// with a 54-byte pixel offset and emits one RGB565 pixel per B,G,R triplet.
module bmp24_stream_to_rgb565(
 input wire clk,reset,start,input wire [7:0] byte_in,input wire byte_valid,
 output reg active,frame_done,format_error,pixel_valid,
 output reg [18:0] pixel_addr,output reg [15:0] pixel_rgb565
);
 reg [31:0] pos,offset;
 reg [7:0] blue,green;
 reg [1:0] phase;
 reg [9:0] x,y;
 reg [18:0] row_base;
 always @(posedge clk or posedge reset) begin
  if(reset) begin
   active<=0;frame_done<=0;format_error<=0;pixel_valid<=0;
   pos<=0;offset<=0;phase<=0;x<=0;y<=0;row_base<=306560;
   pixel_addr<=0;pixel_rgb565<=0;blue<=0;green<=0;
  end else begin
   frame_done<=0;pixel_valid<=0;
   if(start) begin
    active<=1;format_error<=0;pos<=0;offset<=0;phase<=0;x<=0;y<=0;row_base<=306560;
   end else if(active && byte_valid) begin
    pos<=pos+1'b1;
    case(pos)
     0: if(byte_in!=8'h42) format_error<=1;
     1: if(byte_in!=8'h4d) format_error<=1;
     10: offset[7:0]<=byte_in;
     11: offset[15:8]<=byte_in;
     12: offset[23:16]<=byte_in;
     13: offset[31:24]<=byte_in;
     14: if(byte_in!=40) format_error<=1;
     15,16,17: if(byte_in!=0) format_error<=1;
     18: if(byte_in!=8'h80) format_error<=1;
     19: if(byte_in!=2) format_error<=1;
     20,21: if(byte_in!=0) format_error<=1;
     22: if(byte_in!=8'he0) format_error<=1;
     23: if(byte_in!=1) format_error<=1;
     24,25: if(byte_in!=0) format_error<=1;
     26: if(byte_in!=1) format_error<=1;
     27: if(byte_in!=0) format_error<=1;
     28: if(byte_in!=24) format_error<=1;
     29,30,31,32,33: if(byte_in!=0) format_error<=1;
     53: if(offset!=54) format_error<=1;
    endcase
    if(format_error) active<=0;
    else if(pos>=54) begin
     case(phase)
      0: begin blue<=byte_in;phase<=1;end
      1: begin green<=byte_in;phase<=2;end
      2: begin
       pixel_rgb565<={byte_in[7:3],green[7:2],blue[7:3]};
       pixel_addr<=row_base+{9'd0,x};pixel_valid<=1;phase<=0;
       if(x==639) begin
        x<=0;y<=y+1'b1;row_base<=row_base-640;
        if(y==479) begin active<=0;frame_done<=1;end
       end else x<=x+1'b1;
      end
     endcase
    end
   end
  end
 end
endmodule
