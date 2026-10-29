#include "Vbmp24_stream_to_rgb565.h"
#include "verilated.h"
#include <cstdint>
#include <iostream>
#include <stdexcept>
double sc_time_stamp(){return 0;}
int main() {
 Vbmp24_stream_to_rgb565 d;
 unsigned pixels=0,done=0;
 auto tick=[&](){
  d.clk=0;d.eval();d.clk=1;d.eval();
  if(d.pixel_valid) {
   unsigned n=pixels++;
   if(d.pixel_addr!=(479-n/640)*640+n%640 || d.pixel_rgb565!=0xf800)
    throw std::runtime_error("pixel address/color mismatch");
  }
  done+=d.frame_done;
 };
 d.reset=1;d.start=0;d.byte_valid=0;tick();d.reset=0;
 auto begin=[&](){d.byte_valid=0;d.start=1;tick();d.start=0;};
 auto send=[&](uint8_t b){d.byte_in=b;d.byte_valid=1;tick();d.byte_valid=0;tick();};
 uint8_t header[54]={};
 header[0]='B';header[1]='M';header[10]=54;header[14]=40;
 header[18]=0x80;header[19]=2;header[22]=0xe0;header[23]=1;
 header[26]=1;header[28]=24;
 begin();
 for(auto b:header) send(b);
 for(unsigned i=0;i<307200;i++){send(0);send(0);send(255);}
 if(pixels!=307200 || done!=1 || d.active || d.format_error)
  throw std::runtime_error("frame count/done error");
 for(unsigned bad: {0u,10u,14u,18u,19u,20u,22u,23u,24u,26u,27u,28u,29u,30u,31u,32u,33u}) {
  begin();
  for(unsigned i=0;i<54;i++) send(header[i] ^ (i==bad?1:0));
  if(!d.format_error) throw std::runtime_error("invalid header accepted");
 }
 std::cout<<"PASS: 307200 pixels, RGB565, bottom-up mapping, done pulse and 17 invalid headers\n";
}
