#include "Vmedia_controls.h"
#include "verilated.h"
#include <cassert>
#include <iostream>
double sc_time_stamp(){return 0;}
int main(){
 Vmedia_controls d;
 auto tick=[&](int key,int frame){
  d.key_col=d.key_row==7 ? (15^key):15;
  d.frame_end=frame;d.clk=0;d.eval();d.clk=1;d.eval();
 };
 auto wait=[&](int n,int key){for(int i=0;i<n;i++)tick(key,0);};
 auto press=[&](int key){wait(160,key);wait(160,0);};
 auto frame=[&](){tick(0,1);tick(0,0);};
 d.reset=1;tick(0,0);d.reset=0;d.ready=1;wait(100,0);
 assert(!d.video_mode && !d.auto_mode && !d.paused);
 press(2);frame();assert(d.image_index==1);
 press(1);frame();assert(d.image_index==0);
 press(1);frame();assert(d.image_index==2);
 press(4);assert(d.auto_mode);for(int i=0;i<5;i++)frame();assert(d.image_index==0);
 press(4);assert(!d.auto_mode);
 press(8);assert(d.video_mode);
 press(4);assert(d.paused);wait(500,4);assert(!d.paused);wait(500,4);assert(!d.paused);wait(160,0);
 press(4);assert(d.paused);
 press(2);frame();assert(d.image_index==0);
 d.ready=0;press(8);assert(!d.video_mode && d.paused && !d.auto_mode);
 press(8);assert(d.video_mode && d.paused);
 std::cout<<"PASS: matrix debounce, hold, manual/auto, mode while loading, pause persistence\n";
}
