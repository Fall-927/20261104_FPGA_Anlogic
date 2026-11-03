module signage_osd #(parameter PHOTO_COUNT=8,FPS=60)(
 input clk,reset,input [9:0] x,y,input hs,vs,de,input [23:0] rgb_in,
 input video_mode,paused,auto_mode,ready,failed,input [2:0] image_index,
 input [2:0] scene,input [1:0] period_selector,input [4:0] brightness,contrast,volume,
 input [1:0] layout_mode,group_selector,input [15:0] countdown_seconds,input countdown_running,audio_error,
 input settings_visible,output reg [9:0] out_x,out_y,
 output reg out_hs,out_vs,out_de,output reg [23:0] rgb_out
);
 reg [5:0] frames;reg [3:0] h10,h1,m10,m1,s10,s1;reg [9:0] scroll;
 reg [15:0] cd_remaining;
 reg [3:0] cd_minutes,cd_tens,cd_ones;
 reg [1:0] cd_state;
 always @(posedge clk or posedge reset)begin
  if(reset)begin cd_remaining<=0;cd_minutes<=0;cd_tens<=0;cd_ones<=0;cd_state<=0;end
  else if(x==0 && y==493)begin
   cd_remaining<=countdown_seconds;cd_minutes<=0;cd_tens<=0;cd_state<=1;
  end else case(cd_state)
   1:if(cd_remaining>=60)begin cd_remaining<=cd_remaining-60;cd_minutes<=cd_minutes+1'b1;end
     else cd_state<=2;
   2:if(cd_remaining>=10)begin cd_remaining<=cd_remaining-10;cd_tens<=cd_tens+1'b1;end
     else begin cd_ones<=cd_remaining[3:0];cd_state<=0;end
  endcase
 end
 always @(posedge clk or posedge reset)begin
  if(reset)begin frames<=0;h10<=0;h1<=0;m10<=0;m1<=0;s10<=0;s1<=0;scroll<=0;end
  else if(x==0 && y==492)begin
   scroll<=scroll==671 ? 0:scroll+1'b1;
   if(frames==FPS-1)begin
    frames<=0;if(s1<9)s1<=s1+1'b1;
    else begin s1<=0;if(s10<5)s10<=s10+1'b1;
     else begin s10<=0;if(m1<9)m1<=m1+1'b1;
      else begin m1<=0;if(m10<5)m10<=m10+1'b1;
       else begin m10<=0;if(h1<9)h1<=h1+1'b1;
        else begin h1<=0;h10<=h10==9 ? 0:h10+1'b1;end
       end
      end
     end
    end
   end else frames<=frames+1'b1;
  end
 end
 reg [23:0] base,ink;reg [7:0] label_id;reg [6:0] cell_index;
 reg [3:0] font_row;reg [2:0] font_col;reg text_valid;
 integer tx,ty,ticker_pos;
 task line;
  input integer left,top,cells,scale,id;input [23:0] color;
  begin
   if(x>=left && x<left+cells*8*scale && y>=top && y<top+16*scale)begin
    tx=(x-left)/scale;ty=(y-top)/scale;label_id=id;cell_index=tx/8;
    font_col=tx%8;font_row=ty;text_valid=1;ink=color;
   end
  end
 endtask
 task number;
  input integer left,top,value;
  begin
   if(x>=left && x<left+16 && y>=top && y<top+16)begin
    label_id=44;cell_index=x<left+8 ? value/10:value%10;
    font_col=(x-left)%8;font_row=y-top;text_valid=1;ink=24'heaf4f5;
   end
  end
 endtask
 always @*begin
  base=24'h0d1b23;ink=24'hebf2f4;label_id=0;cell_index=0;
  font_row=0;font_col=0;text_valid=0;tx=0;ty=0;ticker_pos=0;
  if(x>=8 && x<504 && y>=56 && y<428)base=rgb_in;
  if(y<48)base=24'h172e38;
  if(y==47 || (x==511 && y>=56 && y<428))base=24'h41606b;
  if(x<184 && y<48)base=24'hf3efe4;
  if(x>=8 && x<12 && y>=10 && y<38)base=24'hb48b54;
  line(18,8,10,2,0,24'h942e35);
  line(200,6,24,1,1,24'hd7e5e7);line(200,27,8,1,2,24'h8fb3bc);
  if(x>=272 && x<336 && y>=27 && y<43)begin
   tx=x-272;label_id=44;font_col=tx%8;font_row=y-27;text_valid=1;
   case(tx/8)
    0:cell_index={3'b0,h10};1:cell_index={3'b0,h1};2:cell_index=10;
    3:cell_index={3'b0,m10};4:cell_index={3'b0,m1};5:cell_index=10;
    6:cell_index={3'b0,s10};default:cell_index={3'b0,s1};
   endcase
  end
  line(520,7,8,1,35,24'hddb675);line(520,27,12,1,17,24'h9ab3b9);
  line(520,60,8,1,3,24'hddb675);line(520,84,12,1,4,24'hd5e0e3);
  line(520,105,11,1,5,24'hd5e0e3);line(520,128,14,1,6,24'h839aa3);
  line(520,157,8,1,7,24'hddb675);
  line(520,181,8,1,video_mode ? (paused ? 11:10):(auto_mode ? 8:9),24'he8f2f0);
  number(520,204,{29'd0,image_index}+1);number(552,204,PHOTO_COUNT);
  if(x>=540 && x<548 && y>=204 && y<220)begin
   label_id=44;cell_index=11;font_col=x-540;font_row=y-204;text_valid=1;
  end
  number(584,204,period_selector==0 ? 5:period_selector==1 ? 10:period_selector==2 ? 15:30);
  line(608,204,2,1,47,24'h9fb8c0);
  line(520,235,8,1,12,24'hddb675);
  line(520,259,4,1,13,24'hb6cbd0);number(608,259,brightness);
  line(520,280,6,1,14,24'hb6cbd0);number(608,280,contrast);
  line(520,301,4,1,15,24'hb6cbd0);number(608,301,volume);
  line(520,329,8,1,16,24'h8abdb5);
  if(x>=568 && x<602 && ((y>=265 && y<269)||(y>=286 && y<290)||(y>=307 && y<311)))begin
   base=24'h29444e;
   if((x-568)<(y<280 ? brightness:y<300 ? contrast:volume)*2)base=24'h62c9b5;
  end
  if(x>=520 && x<632 && (y==148 || y==226 || y==322 || y==418))base=24'h38505a;
  if(x>=520 && x<632 && y>=358 && y<414 && video_mode && scene==0)base=rgb_in;
  if(!video_mode)begin
   line(520,357,8,1,64,24'hddb675);
   line(520,380,8,1,65+group_selector,24'he4ede8);
   line(520,399,10,1,34,24'h9fb8c0);
  end
  if(scene!=0 && x>=8 && x<504 && y>=56 && y<428)begin
   base=scene==3 ? 24'h411c23:scene==2 ? 24'h183f3e:24'hdceeea;
   if(x>=32 && x<480 && y>=88 && y<396)
    base=scene==3 ? 24'h742b32:scene==2 ? 24'h102c31:24'hf6f4eb;
   if(y>=88 && y<94 && x>=32 && x<480)base=scene==3 ? 24'hf18271:24'h67b8a8;
   if(scene==1)begin
    line(192,134,8,2,19,24'h236a62);line(80,212,22,2,20,24'h284b4d);
    line(144,274,14,2,21,24'h46736c);
   end else if(scene==2)begin
    line(160,134,12,2,22,24'hfff1c8);line(96,204,22,1,23,24'hc6ddda);
    if(x>=88 && x<424 && y>=252 && y<306)base=24'hdbb967;
    line(160,262,12,2,24,24'h223d40);line(96,338,24,1,25,24'hbdd6d1);
   end else if(scene==3)begin
    line(160,132,12,2,26,24'hfff0d3);line(80,204,22,2,27,24'hfff4e3);
    line(144,268,14,2,28,24'hffd88a);line(96,338,24,1,29,24'hf5d3cc);
   end else if(scene==4)begin
    line(192,134,8,2,50,24'h236a62);
    line(96,220,20,2,51,24'h284b4d);
    line(112,300,20,1,52,24'h46736c);
   end else begin
    line(192,134,8,2,53,24'h236a62);
    line(96,220,20,2,54,24'h284b4d);
    line(112,300,20,1,55,24'h46736c);
   end
  end
  if(y>=436 && y<462)base=scene==3 ? 24'h7b3036:24'h1d3c43;
  if(y==436)base=scene==3 ? 24'hf3ab80:24'h56847f;
  if(y>=442 && y<458 && x>=8 && x<632)begin
   ticker_pos=x-8+scroll;if(ticker_pos>=672)ticker_pos=ticker_pos-672;
   label_id=scene==3 ? 31:30;cell_index=ticker_pos/8;
   font_col=ticker_pos%8;font_row=y-442;text_valid=1;ink=24'hf2e6be;
  end
  line(8,464,24,1,33,24'h748c97);line(472,464,20,1,32,24'h748c97);
  if(settings_visible && x==516 && y>=235 && y<320)base=24'hddb675;
  if(!ready && scene==0 && x>=8 && x<504 && y>=56 && y<428)begin
   base=24'h10262e;line(160,204,12,2,49,24'h7ca4ab);
  end
  if(failed && x>=8 && x<504 && y>=400 && y<428)begin
   base=24'h742b32;line(16,405,12,1,48,24'hffddbb);
  end
  if(layout_mode==0 && scene==0 && ready && !failed)begin
   base=rgb_in;text_valid=0;
  end
  if(layout_mode==2 && scene==0 && ready && !failed && x>=8 && x<504 && y>=56 && y<428)begin
   base=24'h10262e;text_valid=0;
   if(x>=16 && x<496 && y>=124 && y<412)base=rgb_in;
   line(32,64,12,2,56,24'hddb675);
   line(32,102,26,1,57,24'hb8d0cf);
  end
  if(countdown_running && scene==0 && x>=280 && x<496 && y>=56 && y<82)begin
   base=24'h173e46;text_valid=0;
   line(288,61,8,1,58,24'hf3dfad);
   if(x>=368 && x<408 && y>=61 && y<77)begin
    label_id=44;font_col=(x-368)%8;font_row=y-61;text_valid=1;ink=24'heaf4f5;
    case((x-368)/8)
     0:cell_index=cd_minutes==10 ? 1:0;
     1:cell_index=cd_minutes==10 ? 0:cd_minutes;
     2:cell_index=10;
     3:cell_index=cd_tens;
     default:cell_index=cd_ones;
    endcase
   end
  end
  if(!ready || failed)begin
   if(x>=8 && x<504 && y>=56 && y<428 && scene==0)begin
    base=24'h17323a;text_valid=0;
    line(128,144,16,2,failed ? 59:49,24'hf0ddb8);
    line(112,224,28,1,60,24'hc5dddb);
    line(112,272,28,1,61,24'hc5dddb);
    line(112,320,28,1,62,24'hc5dddb);
   end
  end
  if(audio_error && x>=520 && y>=329 && y<345)begin
   base=24'h742b32;text_valid=0;line(520,329,14,1,63,24'hffddbb);
  end
 end
 wire [7:0] font_pixels;
 signage_font font(.clk(clk),.label_id(label_id),.cell_index(cell_index),.row(font_row),.pixels(font_pixels));
 reg [23:0] base1,ink1;reg [2:0] col1;reg valid1,hs1,vs1,de1;reg [9:0] x1,y1;
 always @(posedge clk or posedge reset)begin
  if(reset)begin
   base1<=0;ink1<=0;col1<=0;valid1<=0;hs1<=1;vs1<=1;de1<=0;x1<=0;y1<=0;
   out_x<=0;out_y<=0;out_hs<=1;out_vs<=1;out_de<=0;rgb_out<=0;
  end else begin
   base1<=base;ink1<=ink;col1<=font_col;valid1<=text_valid;
   x1<=x;y1<=y;hs1<=hs;vs1<=vs;de1<=de;
   out_x<=x1;out_y<=y1;out_hs<=hs1;out_vs<=vs1;out_de<=de1;
   rgb_out<=!de1 ? 24'd0 : valid1 && font_pixels[7-col1] ? ink1:base1;
  end
 end
endmodule
