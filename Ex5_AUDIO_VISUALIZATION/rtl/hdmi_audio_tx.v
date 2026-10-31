// HDMI 640x480/60 transmitter extension: stereo LPCM, 48 kHz, 1 kHz tone.
// Fixed 25.2 MHz pixel clock: Fs = Fpixel/525; N=6144, CTS=25200.
// Packet layout, BCH and TERC4 adapted from hdl-util/hdmi by Sameer Puri
// (MIT, see LICENSES/hdl-util-hdmi-MIT.txt and THIRD_PARTY_NOTICES.md).
// Only synchronous enables are used; no fabric-generated audio clock.
module hdmi_audio_tx #(parameter EXTERNAL_PCM=0)(
 input wire clk,reset,play,
 input wire [9:0] x,y,
 input wire hs,vs,de,
 input wire [7:0] red,green,blue,
 input wire [15:0] pcm_left,pcm_right,
 output reg [9:0] symbol_b,symbol_g,symbol_r,
 output reg audio_overflow,
 output wire sample_tick
);
 reg [9:0] sample_div;
 reg [5:0] tone_phase;
 reg [7:0] iec_frame;
 reg playing;
 assign sample_tick=sample_div==10'd524;
 // 48 samples per cycle, peak 4096 (~-18 dBFS), identical L/R.
 function [15:0] sine;
  input [5:0] p;
  begin case(p)
   0:sine=0;1:sine=535;2:sine=1060;3:sine=1567;
   4:sine=2048;5:sine=2493;6:sine=2896;7:sine=3250;
   8:sine=3547;9:sine=3784;10:sine=3956;11:sine=4061;
   12:sine=4096;13:sine=4061;14:sine=3956;15:sine=3784;
   16:sine=3547;17:sine=3250;18:sine=2896;19:sine=2493;
   20:sine=2048;21:sine=1567;22:sine=1060;23:sine=535;
   24:sine=0;25:sine=-16'sd535;26:sine=-16'sd1060;27:sine=-16'sd1567;
   28:sine=-16'sd2048;29:sine=-16'sd2493;30:sine=-16'sd2896;31:sine=-16'sd3250;
   32:sine=-16'sd3547;33:sine=-16'sd3784;34:sine=-16'sd3956;35:sine=-16'sd4061;
   36:sine=-16'sd4096;37:sine=-16'sd4061;38:sine=-16'sd3956;39:sine=-16'sd3784;
   40:sine=-16'sd3547;41:sine=-16'sd3250;42:sine=-16'sd2896;43:sine=-16'sd2493;
   44:sine=-16'sd2048;45:sine=-16'sd1567;46:sine=-16'sd1060;47:sine=-16'sd535;
   default:sine=0;
  endcase end
 endfunction
 wire [23:0] sample_left=((EXTERNAL_PCM || playing) && play) ?
  (EXTERNAL_PCM ? {pcm_left,8'd0}:{sine(tone_phase),8'd0}):24'd0;
 wire [23:0] sample_right=((EXTERNAL_PCM || playing) && play) ?
  (EXTERNAL_PCM ? {pcm_right,8'd0}:{sine(tone_phase),8'd0}):24'd0;
 // IEC60958 consumer PCM, copyright not asserted, channels 1/2,
 // 48 kHz, 16-bit sample in a left-aligned 24-bit transport word.
 localparam [191:0] STATUS_L={152'd0,8'hd2,8'h02,8'h10,8'h00,8'h04};
 localparam [191:0] STATUS_R={152'd0,8'hd2,8'h02,8'h20,8'h00,8'h04};
 wire cl=STATUS_L[iec_frame],cr=STATUS_R[iec_frame];
 wire pl=(^sample_left)^cl,pr=(^sample_right)^cr;
 wire [55:0] sample_sub={pr,cr,2'b00,pl,cl,2'b00,sample_right,sample_left};
 reg [55:0] fifo[0:15];
 reg [15:0] block_start;
 reg [3:0] wp,rp;
 wire [3:0] rp1=rp+4'd1,rp2=rp+4'd2,rp3=rp+4'd3;
 reg [4:0] used;
 // Three adjacent packets per line: 654..749. Payload never overlaps DE.
 wire prepare=(x==653 || x==685 || x==717);
 wire acr_due=(x==653 && y[4:0]==0);
 wire avi_due=(x==653 && y==1);
 wire info_due=(x==653 && y==2);
 wire gcp_due=(x==653 && y==3);
 wire take_audio=prepare && !acr_due && !avi_due && !info_due && !gcp_due && used!=0;
 wire [2:0] take_count=take_audio ? (used>=4 ? 3'd4:used[2:0]):3'd0;
 wire push=sample_tick && (used<16 || take_count!=0);
 reg [23:0] header;
 reg [55:0] sub0,sub1,sub2,sub3;
 reg [7:0] ecc_h,ecc0,ecc1,ecc2,ecc3;
 wire island=x>=654 && x<750;
 wire [9:0] packet_offset=x-10'd654;
 wire [4:0] pc=packet_offset[4:0];
 wire [5:0] bit0={pc,1'b0},bit1={pc,1'b1};
 wire [63:0] bch0={ecc0,sub0},bch1={ecc1,sub1},bch2={ecc2,sub2},bch3={ecc3,sub3};
 wire [31:0] bchh={ecc_h,header};
 function [7:0] ecc;
  input [7:0] old;
  input bit_in;
  begin ecc=(old>>1)^((old[0]^bit_in) ? 8'h83:8'h00);end
 endfunction
 function [9:0] terc;
  input [3:0] v;
  begin case(v)
   0:terc=10'b1010011100;1:terc=10'b1001100011;
   2:terc=10'b1011100100;3:terc=10'b1011100010;
   4:terc=10'b0101110001;5:terc=10'b0100011110;
   6:terc=10'b0110001110;7:terc=10'b0100111100;
   8:terc=10'b1011001100;9:terc=10'b0100111001;
   10:terc=10'b0110011100;11:terc=10'b1011000110;
   12:terc=10'b1010001110;13:terc=10'b1001110001;
   14:terc=10'b0101100011;15:terc=10'b1011000011;
  endcase end
 endfunction
 // Packet preparation is one clock before each 32-pixel packet.
 // Concurrent push/pop uses one count update, so a sample is never lost.
 always @(posedge clk or posedge reset) begin
  if(reset) begin
   sample_div<=0;tone_phase<=0;iec_frame<=0;playing<=0;
   wp<=0;rp<=0;used<=0;block_start<=0;audio_overflow<=0;
   header<=0;sub0<=0;sub1<=0;sub2<=0;sub3<=0;
   ecc_h<=0;ecc0<=0;ecc1<=0;ecc2<=0;ecc3<=0;
  end else begin
   if(x==0 && y==0) playing<=play;
   if(sample_tick) begin
    sample_div<=0;
    if(playing && play) tone_phase<=tone_phase==47 ? 0:tone_phase+1'b1;
    else tone_phase<=0;
    iec_frame<=iec_frame==191 ? 0:iec_frame+1'b1;
    if(!push) audio_overflow<=1;
   end else sample_div<=sample_div+1'b1;
   if(push) begin fifo[wp]<=sample_sub;block_start[wp]<=iec_frame==0;wp<=wp+1'b1;end
   used<=used+{4'd0,push}-{2'd0,take_count};
   if(take_audio) rp<=rp+{1'd0,take_count};
   if(prepare) begin
    header<=0;sub0<=0;sub1<=0;sub2<=0;sub3<=0;
    if(acr_due) begin
     header<=24'h000001;
     // PB0=0, PB1..3=CTS (MSB first), PB4..6=N (MSB first).
     sub0<=56'h00180070620000;sub1<=56'h00180070620000;
     sub2<=56'h00180070620000;sub3<=56'h00180070620000;
    end else if(avi_due) begin
     header<=24'h0d0282;
     // RGB, 4:3, active aspect same as picture, IT/full-range, VIC1.
     // PB0 checksum 0xce; PB1=0 PB2=0x18 PB3=0x88 PB4=1.
     sub0<=56'h000001881800ce;
    end else if(info_due) begin
     // Explicit LPCM, 2 channels, 48 kHz, 16-bit (not "refer to stream").
     // Checksum 0x53 + 0x84 + 1 + 10 + 0x11 + 0x0d = 0x100.
     header<=24'h0a0184;sub0<=56'h000000000d1153;
    end else if(gcp_due) begin
     // Re-assert Clear_AVMUTE once per frame; color-depth code 0 = 24bpp.
     header<=24'h000003;sub0<=56'h00000000000010;
    end else if(take_audio) begin
     header[7:0]<=8'h02;
     header[8]<=1;header[20]<=block_start[rp];sub0<=fifo[rp];
     if(take_count>=2) begin header[9]<=1;header[21]<=block_start[rp1];sub1<=fifo[rp1];end
     if(take_count>=3) begin header[10]<=1;header[22]<=block_start[rp2];sub2<=fifo[rp2];end
     if(take_count>=4) begin header[11]<=1;header[23]<=block_start[rp3];sub3<=fifo[rp3];end
    end
   end
   if(!island || pc==31) begin ecc_h<=0;ecc0<=0;ecc1<=0;ecc2<=0;ecc3<=0;end
   else begin
    if(pc<24) ecc_h<=ecc(ecc_h,header[pc]);
    if(pc<28) begin
     ecc0<=ecc(ecc(ecc0,sub0[bit0]),sub0[bit1]);
     ecc1<=ecc(ecc(ecc1,sub1[bit0]),sub1[bit1]);
     ecc2<=ecc(ecc(ecc2,sub2[bit0]),sub2[bit1]);
     ecc3<=ecc(ecc(ecc3,sub3[bit0]),sub3[bit1]);
    end
   end
  end
 end
 // Existing video encoder supplies one-cycle registered video/control codes.
 wire dip=x>=644 && x<652;
 wire next_video_line=(y<479 || y==524);
 wire vp=x>=790 && x<798 && next_video_line;
 wire vg=x>=798 && next_video_line;
 wire dg=(x>=652 && x<654)||(x>=750 && x<752);
 wire [9:0] vb,vg_code,vr;
 tmds_encoder eb(.clk(clk),.reset(reset),.de(de),.c0(hs),.c1(vs),.data(blue),.symbol(vb));
 tmds_encoder eg(.clk(clk),.reset(reset),.de(de),.c0(dip||vp),.c1(1'b0),.data(green),.symbol(vg_code));
 tmds_encoder er(.clk(clk),.reset(reset),.de(de),.c0(dip),.c1(1'b0),.data(red),.symbol(vr));
 reg [1:0] mode_d;
 reg [9:0] aux_b,aux_g,aux_r;
 always @(posedge clk or posedge reset) begin
  if(reset) begin mode_d<=0;aux_b<=0;aux_g<=0;aux_r<=0;end
  else begin
   mode_d<=island ? 1:dg ? 2:vg ? 3:0;
   if(island) begin
    aux_b<=terc({1'b1,bchh[pc],vs,hs});
    aux_g<=terc({bch3[bit0],bch2[bit0],bch1[bit0],bch0[bit0]});
    aux_r<=terc({bch3[bit1],bch2[bit1],bch1[bit1],bch0[bit1]});
   end else if(dg) begin aux_b<=terc({2'b11,vs,hs});aux_g<=10'b0100110011;aux_r<=10'b0100110011;end
   else begin aux_b<=10'b1011001100;aux_g<=10'b0100110011;aux_r<=10'b1011001100;end
  end
 end
 always @* begin
  symbol_b=vb;symbol_g=vg_code;symbol_r=vr;
  if(mode_d!=0) begin symbol_b=aux_b;symbol_g=aux_g;symbol_r=aux_r;end
 end
endmodule
