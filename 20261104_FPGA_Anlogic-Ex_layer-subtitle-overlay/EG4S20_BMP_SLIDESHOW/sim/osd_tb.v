`timescale 1ns/1ps
module osd_tb;
 reg clk=0,reset=1,enable=0,hs=1,vs=1,de=0;
 reg [9:0] x=0,y=0;
 reg [23:0] rgb_in=0;
 reg [1:0] image_index=0;
 reg auto_mode=0;
 wire [9:0] ox,oy;
 wire oh,ov,od,op;
 wire [23:0] rgb_out;
 slideshow_osd #(.FRAMES_PER_SECOND(2),.SCROLL_FRAME_DIV(2)) dut(
 .clk(clk),.reset(reset),.enable(enable),.x(x),.y(y),.hs(hs),.vs(vs),.de(de),
 .rgb_in(rgb_in),.image_index(image_index),.auto_mode(auto_mode),
 .out_x(ox),.out_y(oy),.out_hs(oh),.out_vs(ov),.out_de(od),.out_play(op),.rgb_out(rgb_out));
 integer checks=0,i,j,k,pixels=0,fd;
 reg [1023:0] preview_path;
 task tick;
  begin #5;clk=1;#5;clk=0;end
 endtask
 task check;
  input ok;
  input [511:0] description;
  begin checks=checks+1;if(!ok) begin $display("FAIL %0s x=%0d y=%0d rgb=%h",description,x,y,rgb_out);$fatal(1);end end
 endtask
 task point;
  input [9:0] px,py;
  input [23:0] expected;
  begin
   x=px;y=py;de=(px<640 && py<480);hs=!(px>=656 && px<752);vs=!(py>=490 && py<492);
   tick;tick;
   check(ox==px && oy==py && od==de && oh==hs && ov==vs && op==enable,"two-stage timing alignment");
   check(rgb_out===expected,"pixel blend / glyph / bypass");
  end
 endtask
 task frame;
  begin x=0;y=492;de=0;tick;x=1;tick;x=0;y=524;tick;x=1;tick;end
 endtask
 reg [9:0] prev_x,prev_y;
 reg prev_hs,prev_vs,prev_de;
 reg [23:0] prev_rgb;
 initial begin
  tick;reset=0;rgb_in=24'h6496c8;
  point(100,100,24'h6496c8);
  point(35,24,24'h6496c8); // disabled text is transparent
  enable=1;
  point(100,100,24'h6496c8);
  point(20,12,24'h365374); // 50% navy over (100,150,200)
  point(16,12,24'h2b99b9); // accent over blended panel
  point(34,24,24'hffffff); // A row 0 column 1, scale 2
  point(32,24,24'h365374); // A row 0 column 0 is empty
  point(16,440,24'hccbc4d); // W row 0 col 0, 75% yellow over panel
  point(16,442,24'hccbc4d);
  point(26,444,24'h1b293a); // W shadow in inter-character gap
  point(640,100,24'h000000);
  point(700,490,24'h000000);
  check(dut.message_char(0)=="W" && dut.message_char(25)=="H" &&
        dut.message_char(47)=="L" && dut.message_char(63)==" ","64-character message layout");
  // Per-frame movement, never every scanline. Wrap naturally at 1024px.
  for(i=0;i<2048;i=i+1) begin
   frame;
   check(dut.scroll_offset==((i+1)/2)%1024,"scroll cadence and cyclic wrap");
   check(dut.frame_time[3:0]==(((i+1)/2)%10),"second BCD snapshot");
  end
  check(dut.scroll_offset==0,"full scrolling wrap");
  check(dut.frame_time==24'h001704,"minutes/seconds carry");
  enable=0;for(i=0;i<4;i=i+1) frame;
  check(dut.frame_time==24'h001704 && dut.scroll_offset==0,"disabled timer and motion freeze");
  enable=1;image_index=2;auto_mode=1;frame;
  check(dut.frame_image==2 && dut.frame_auto==1,"frame-atomic image/mode snapshot");
  check(dut.status_char(12)=="3" && dut.status_char(16)=="A","dynamic header content");
  x=0;y=20;image_index=1;auto_mode=0;tick;
  check(dut.frame_image==2 && dut.frame_auto==1,"no mid-frame header changes");
  // Reach hour carry and 99-hour wrap with accelerated frame enables.
  for(i=2049;i<7200;i=i+1) frame;
  check(dut.frame_time==24'h010000,"hours carry");
  dut.ht=9;dut.hu=9;dut.mt=5;dut.mu=9;dut.st=5;dut.su=9;dut.second_frames=1;
  frame;check(dut.frame_time==0,"99:59:59 wraps to 00:00:00");
  // Synchronous data must remain aligned at every pixel/line/frame boundary.
  reset=1;tick;reset=0;enable=0;
  prev_x=0;prev_y=0;prev_hs=1;prev_vs=1;prev_de=0;prev_rgb=0;
  for(i=0;i<420003;i=i+1) begin
   x=i%800;y=(i/800)%525;de=x<640 && y<480;
   hs=!(x>=656 && x<752);vs=!(y>=490 && y<492);
   rgb_in={x[7:0],y[7:0],8'h55};tick;
   if(i!=0) begin
    check(ox==prev_x && oy==prev_y && oh==prev_hs && ov==prev_vs && od==prev_de,"raster pipeline sidebands");
    check(rgb_out==(prev_de ? prev_rgb:24'd0),"raster pixel pipeline");
   end
   prev_x=x;prev_y=y;prev_hs=hs;prev_vs=vs;prev_de=de;prev_rgb=rgb_in;
  end
  // Optional PPM from actual simulated output, not a hand-drawn mockup.
  if($value$plusargs("preview=%s",preview_path)) begin
   fd=$fopen(preview_path,"w");check(fd!=0,"open preview");
   $fwrite(fd,"P3\n640 480\n255\n");enable=1;image_index=0;auto_mode=0;frame;
   for(j=0;j<480;j=j+1) for(k=0;k<640;k=k+1) begin
    x=k;y=j;de=1;hs=1;vs=1;rgb_in={8'd48+k[7:2],8'd64+j[7:2],8'd112};
    tick;tick;$fwrite(fd,"%0d %0d %0d\n",rgb_out[23:16],rgb_out[15:8],rgb_out[7:0]);
   end
   $fclose(fd);
  end
  $display("PASS OSD: %0d checks, raster, alpha, glyphs, shadow, 1024px wrap, BCD carries, frame snapshots",checks);
  $finish;
 end
endmodule
