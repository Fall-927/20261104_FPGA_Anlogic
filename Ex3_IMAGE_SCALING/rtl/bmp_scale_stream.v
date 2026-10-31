// Positive-height 24-bit BI_RGB BMP -> bottom-up 640x480 RGB565.
// One source-row RAM, nearest-neighbour, integer DDA, centered letterbox.
// Input and output ready/valid allow SD and SDRAM to run at unrelated rates.
module bmp_scale_stream(
 input clk,reset,input [7:0] byte_in,input byte_valid,output byte_ready,
 output reg [15:0] pixel,output reg pixel_valid,input pixel_ready,
 output reg frame_done,error,output reg [31:0] sector_count,
 output reg [15:0] source_width,source_height,
 output reg [9:0] display_width,display_height
);
 localparam HEADER=0,CHECK=1,DIV_START=2,DIV_WAIT=3,PREFIX=4,ROW=5,
  ROW_END=6,OUTPUT_ROW=7,READ_PIXEL=8,SEND_PIXEL=9,STEP_X=10,
  STEP_Y=11,TRAIL=12,FINISHED=13,FAILED=14,CALCULATE=15;
 reg [3:0] state;
 reg [31:0] position,file_size,offset,dib,width_raw,height_raw,compression;
 reg [15:0] planes,bpp;
 reg [15:0] row_ram[0:1279];
 reg [15:0] row_read;
 reg [15:0] src_row,src_x,target_row;
 reg [12:0] row_byte;
 reg [1:0] component;
 reg [7:0] blue,green;
 reg [9:0] out_x,out_y,content_row,left_pad,bottom_pad;
 reg [15:0] sample_x;
 reg [31:0] x_remainder,y_remainder;
 reg [31:0] stride,payload;
 wire width_limited={16'b0,source_width}*480>={16'b0,source_height}*640;
 wire [31:0] div_n=width_limited ? height_raw*640:width_raw*480;
 wire [31:0] div_d=width_limited ? width_raw:height_raw;
 wire div_busy,div_done;wire [31:0] div_q;
 scale_divider divider(.clk(clk),.reset(reset),.start(state==DIV_START),
  .numerator(div_n),.denominator(div_d),.busy(div_busy),.done(div_done),.quotient(div_q));
 assign byte_ready=state==HEADER || (state==PREFIX && position<offset) || state==ROW || state==TRAIL;
 wire content_y=out_y>=bottom_pad && out_y<bottom_pad+display_height;
 wire in_content=out_x>=left_pad && out_x<left_pad+display_width &&
  out_y>=bottom_pad && out_y<bottom_pad+display_height;
 // Dedicated synchronous RAM process, no reset on storage: infer BRAM.
 always @(posedge clk) begin
  if(state==ROW && byte_valid && row_byte<source_width*3 && component==2)
   row_ram[src_x[10:0]]<={byte_in[7:3],green[7:2],blue[7:3]};
  row_read<=row_ram[sample_x[10:0]];
 end
 always @(posedge clk or posedge reset) begin
  if(reset) begin
   state<=HEADER;position<=0;file_size<=0;offset<=0;dib<=0;width_raw<=0;height_raw<=0;
   compression<=0;planes<=0;bpp<=0;source_width<=0;source_height<=0;
   display_width<=0;display_height<=0;sector_count<=1;frame_done<=0;error<=0;
   pixel<=0;pixel_valid<=0;src_row<=0;src_x<=0;target_row<=0;row_byte<=0;
   stride<=0;payload<=0;
   component<=0;blue<=0;green<=0;out_x<=0;out_y<=0;content_row<=0;
   left_pad<=0;bottom_pad<=0;sample_x<=0;x_remainder<=0;y_remainder<=0;
  end else begin
   case(state)
    HEADER: if(byte_valid) begin
     position<=position+1'b1;
     case(position)
      0: if(byte_in!=8'h42) begin error<=1;state<=FAILED;end
      1: if(byte_in!=8'h4d) begin error<=1;state<=FAILED;end
      2,3,4,5:file_size<={byte_in,file_size[31:8]};
      10,11,12,13:offset<={byte_in,offset[31:8]};
      14,15,16,17:dib<={byte_in,dib[31:8]};
      18,19,20,21:width_raw<={byte_in,width_raw[31:8]};
      22,23,24,25:height_raw<={byte_in,height_raw[31:8]};
      26,27:planes<={byte_in,planes[15:8]};
      28,29:bpp<={byte_in,bpp[15:8]};
      30,31,32,33:compression<={byte_in,compression[31:8]};
      53:state<=CHECK;
     endcase
    end
    CHECK: begin
     // Bounds prevent overflow and out-of-range line RAM accesses.
     if(width_raw==0 || width_raw>1280 || height_raw==0 || height_raw>1024 ||
        dib!=40 || planes!=1 || bpp!=24 || compression!=0 || offset<54 || offset>4096) begin error<=1;state<=FAILED;end
     else begin
      source_width<=width_raw[15:0];source_height<=height_raw[15:0];
      sector_count<=(file_size+511)>>9;
      stride<=((width_raw[10:0]*13'd3+13'd3)&13'h1ffc);state<=CALCULATE;
     end
    end
    CALCULATE:begin payload<=stride[12:0]*source_height[10:0];state<=DIV_START;end
    DIV_START:begin
     if(file_size!=offset+payload) begin error<=1;state<=FAILED;end
     else state<=DIV_WAIT;
    end
    DIV_WAIT:if(div_done) begin
     if(div_q==0) begin error<=1;state<=FAILED;end
     else begin
      display_width<=width_limited ? 640:div_q[9:0];
      display_height<=width_limited ? div_q[9:0]:480;
      left_pad<=width_limited ? 0:(640-div_q[9:0])/2;
      bottom_pad<=width_limited ? (480-div_q[9:0])/2:0;
      state<=PREFIX;
     end
    end
    PREFIX:if(position==offset) state<=ROW;
     else if(byte_valid) position<=position+1'b1;
    ROW:if(byte_valid) begin
     position<=position+1'b1;row_byte<=row_byte+1'b1;
     if(row_byte<source_width*3) begin
      case(component)
       0:begin blue<=byte_in;component<=1;end
       1:begin green<=byte_in;component<=2;end
       2:begin src_x<=src_x+1'b1;component<=0;end
      endcase
     end
     if(row_byte==stride-1) begin row_byte<=0;src_x<=0;state<=ROW_END;end
    end
    ROW_END:begin
     if(out_y<bottom_pad || (content_row<display_height && target_row==src_row) ||
        out_y>=bottom_pad+display_height) begin out_x<=0;sample_x<=0;x_remainder<=0;state<=OUTPUT_ROW;end
     else if(src_row==source_height-1) state<=TRAIL;
     else begin src_row<=src_row+1'b1;state<=ROW;end
    end
    OUTPUT_ROW:begin
     if(in_content) state<=READ_PIXEL;
     else begin pixel<=0;pixel_valid<=1;state<=SEND_PIXEL;end
    end
    READ_PIXEL:begin pixel<=row_read;pixel_valid<=1;state<=SEND_PIXEL;end
    SEND_PIXEL:if(pixel_ready) begin
     pixel_valid<=0;
     if(out_x==639) begin
      out_x<=0;out_y<=out_y+1'b1;
      if(out_y==479) state<=TRAIL;
      else if(content_y) begin
       content_row<=content_row+1'b1;y_remainder<=y_remainder+source_height;state<=STEP_Y;
      end else state<=ROW_END;
     end else begin
      out_x<=out_x+1'b1;
      if(in_content) begin x_remainder<=x_remainder+source_width;state<=STEP_X;end
      else state<=OUTPUT_ROW;
     end
    end
    STEP_X:if(x_remainder>=display_width) begin x_remainder<=x_remainder-display_width;sample_x<=sample_x+1'b1;end
     else state<=OUTPUT_ROW;
    STEP_Y:if(y_remainder>=display_height) begin y_remainder<=y_remainder-display_height;target_row<=target_row+1'b1;end
     else state<=ROW_END;
    TRAIL:begin
     // Remaining source rows are consumed even when the final output row
     // selected an earlier source row; SD completes the sector including CRC.
     if(position>=file_size) begin frame_done<=1;state<=FINISHED;end
     else if(byte_valid) position<=position+1'b1;
    end
    FINISHED:;
    default:begin error<=1;state<=FAILED;end
   endcase
  end
 end
endmodule
