#include "Vav15_memory.h"
#include "verilated.h"
#include <stdexcept>
#include <iostream>
double sc_time_stamp(){return 0;}
int main(){try{
 Vav15_memory d;
 auto tick=[&](){d.mem_clk=0;d.write_clk=0;d.pixel_clk=0;d.eval();d.mem_clk=1;d.write_clk=1;d.pixel_clk=1;d.eval();};
 d.reset=1;d.photo_mode=1;d.image_index=0;d.video_enable=0;d.video_pop=0;d.audio_pop=0;d.word_valid=0;d.refresh_toggle=0;
 tick();tick();d.reset=0;for(int i=0;i<20;i++)tick();
 for(unsigned i=0;i<921600;i++){
  while(!d.word_ready)tick();
  d.word_data=(i%307200)^((i/307200)*12345);d.word_valid=1;tick();d.word_valid=0;
  tick();tick();tick();
 }
 for(int i=0;i<10000&&!d.photos_loaded;i++)tick();
 if(!d.photos_loaded||d.overflow){std::cerr<<"loaded="<<int(d.photos_loaded)<<" overflow="<<int(d.overflow)<<"\n";throw std::runtime_error("photo preload");}
 d.video_enable=1;
 for(unsigned image: {0u,1u,2u,0u}){
  d.image_index=image;for(int i=0;i<10;i++)tick();
  d.refresh_toggle=!d.refresh_toggle;for(int i=0;i<2000;i++)tick();
  for(unsigned y=0;y<480;y++)for(unsigned x=0;x<640;x++){
   if(d.video_empty)throw std::runtime_error("photo underflow");
   unsigned expected=(((479-y)*640+x)^(image*12345))&65535;
   if(d.rgb565!=expected)throw std::runtime_error("photo pixel/order mismatch");
   d.video_pop=1;tick();d.video_pop=0;tick();tick();tick();
  }
 }
 d.reset=1;tick();d.reset=0;d.video_enable=0;
 if(d.photos_loaded)throw std::runtime_error("mode reset did not invalidate photos");
 std::cout<<"PASS: 3 photo preload, 1228800 pixels, BMP row inversion, wrap, reset\n";
}catch(const std::exception&e){std::cerr<<e.what()<<"\n";return 1;}}
