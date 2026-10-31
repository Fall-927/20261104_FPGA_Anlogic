#include "Vslideshow_framebuffer.h"
#include "Vslideshow_framebuffer___024root.h"
#include "verilated.h"
#include <iostream>
#include <stdexcept>
#include <memory>
double sc_time_stamp(){return 0;}
static unsigned pattern(unsigned a){return ((a*73)^(a>>8))&65535;}
int main(){try {
 auto model=std::make_unique<Vslideshow_framebuffer>();
 auto &d=*model;
 auto tick=[&](){d.mem_clk=0;d.write_clk=0;d.pixel_clk=0;d.eval();
 d.mem_clk=1;d.write_clk=1;d.pixel_clk=1;d.eval();};
 d.reset=1;d.pixel_valid=0;d.read_enable=0;d.frame_toggle=0;d.image_index=0;tick();d.reset=0;
 for(int i=0;i<20;i++)tick();
 for(unsigned a=0;a<921600;a++){
  d.pixel=pattern(a);d.pixel_valid=1;tick();d.pixel_valid=0;tick();tick();tick();
 }
 for(int i=0;i<2000 && !d.loaded;i++)tick();
 if(!d.loaded || d.overflow)throw std::runtime_error("preload failed");
 for(unsigned a=0;a<921600;a++)if(d.rootp->slideshow_framebuffer__DOT__ctrl__DOT__memory[a]!=pattern(a))throw std::runtime_error("memory mismatch at "+std::to_string(a));
 auto select=[&](unsigned bank){d.image_index=bank;d.frame_toggle^=1;for(int i=0;i<1000;i++)tick();};
 auto consume=[&](unsigned bank,unsigned size){
  for(unsigned p=0;p<size;p++){
   unsigned address=bank*307200+(479-p/640)*640+p%640;
   if(d.empty || d.rgb565!=pattern(address))throw std::runtime_error("bank "+std::to_string(bank)+" pixel "+std::to_string(p)+" empty "+std::to_string(d.empty)+" actual "+std::to_string(d.rgb565)+" expected "+std::to_string(pattern(address)));
   d.read_enable=1;tick();d.read_enable=0;tick();tick();tick();
  }
 };
 select(0);consume(0,307200);for(int i=0;i<100;i++)tick();
 if(!d.empty)throw std::runtime_error("read past frame end");
 select(2);consume(2,307200);
 select(1);consume(1,1000); // Switch early with unread prefetch still present.
 select(0);consume(0,307200);
 std::cout<<"PASS framebuffer: three-bank preload, row reversal, exact frame limit, FIFO flush and repeat\n";
}catch(const std::exception &e){std::cerr<<e.what()<<std::endl;return 1;}}
