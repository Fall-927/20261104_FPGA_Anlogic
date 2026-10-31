#include "Vaudio_wave_overlay.h"
#include "verilated.h"
#include <stdexcept>
#include <iostream>
double sc_time_stamp(){return 0;}
int main(){try{
 Vaudio_wave_overlay d;
 auto tick=[&](){d.clk=0;d.eval();d.clk=1;d.eval();};
 auto pixel=[&](int x,int y,int r,int g,int b){d.x=x;d.y=y;d.eval();if(d.red_out!=r||d.green_out!=g||d.blue_out!=b)throw std::runtime_error("overlay pixel mismatch");};
 auto samples=[&](int l,int r){d.sample_tick=1;d.pcm_left=l;d.pcm_right=r;for(int i=0;i<1024;i++)tick();d.sample_tick=0;};
 auto frame=[&](){d.frame_end=1;tick();d.frame_end=0;tick();};
 d.reset=1;d.enable=1;d.paused=0;d.frame_end=0;d.sample_tick=0;d.de=1;d.red_in=200;d.green_in=160;d.blue_in=120;tick();d.reset=0;
 pixel(20,400,200,160,120);pixel(66,400,50,40,30);
 samples(32767,-32768);pixel(66,400,50,40,30); // unpublished bank
 frame();
 for(int bin=0;bin<128;bin++){
  int x=65+bin*4;
  pixel(x,385,48,240,96);pixel(x,448,48,240,96);pixel(x,384,50,40,30);pixel(x,449,50,40,30);
 }
 d.paused=1;samples(0,0);frame();pixel(66,400,255,192,96);
 d.paused=0;samples(0,0);pixel(66,400,48,240,96);frame();
 pixel(66,400,50,40,30);pixel(66,416,48,240,96); // actual silence, center only
 d.enable=0;pixel(66,416,200,160,120);d.enable=1;d.de=0;pixel(66,416,200,160,120);
 d.de=1;d.reset=1;tick();d.reset=0;pixel(66,400,50,40,30);
 std::cout<<"PASS waveform: stereo extremes, all 128 bins, vblank publish, freeze, silence, bypass/reset\n";
}catch(const std::exception&e){std::cerr<<e.what()<<"\n";return 1;}}
