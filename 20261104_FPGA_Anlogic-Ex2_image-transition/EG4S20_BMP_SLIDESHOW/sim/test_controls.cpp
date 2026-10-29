#include "Vslideshow_controls.h"
#include "verilated.h"
#include <stdexcept>
#include <iostream>
double sc_time_stamp(){return 0;}
int main(){
 Vslideshow_controls d; unsigned keys=0;
 auto check=[&](bool ok){if(!ok)throw std::runtime_error("transition assertion failed");};
 auto tick=[&](){
  auto index=d.image_index,level=d.fade_level,toggle=d.frame_toggle;
  bool boundary=d.frame_end;
  d.clk=0;d.key_col=d.key_row==7 ? (15^keys):15;d.eval();d.clk=1;d.eval();
  if(!d.reset){
   check(d.fade_level<=32);
   if(!boundary)check(d.image_index==index && d.fade_level==level && d.frame_toggle==toggle);
   if(d.image_index!=index)check(level==0 && d.fade_level==0 && boundary);
  }
 };
 auto run=[&](int n){while(n--)tick();};
 auto frame=[&](){d.frame_end=1;tick();d.frame_end=0;run(2);};
 auto press=[&](unsigned k){keys=k;run(150);keys=0;run(150);};
 auto finish=[&](unsigned expected){for(int i=0;i<70;i++)frame();check(!d.transition_busy && d.fade_level==32 && d.image_index==expected);};
 d.reset=1;d.ready=0;d.frame_end=0;run(3);d.reset=0;run(20);
 press(2);frame();check(d.image_index==0 && !d.transition_busy);
 d.ready=1;press(1);frame();check(d.image_index==0 && d.transition_busy);
 for(int level=31;level>=0;--level){frame();check(d.fade_level==level && d.image_index==0);}
 frame();check(d.image_index==2 && d.fade_level==0);
 for(int level=1;level<=32;++level){frame();check(d.fade_level==level && d.image_index==2);}
 check(!d.transition_busy);
 // Held key triggers only once, including across a complete transition.
 keys=2;run(150);finish(0);run(200);frame();check(!d.transition_busy);
 keys=0;run(150);
 // A request during a transition is retained, without redirecting mid-fade.
 press(2);frame();for(int i=0;i<10;i++)frame();press(2);
 for(int i=0;i<140;i++)frame();check(d.image_index==2 && !d.transition_busy);
 // Auto dwell is counted only at full brightness, not during transitions.
 press(4);check(d.auto_mode);frame();frame();frame();frame();check(d.transition_busy);
 press(4);check(!d.auto_mode);finish(0);
 for(int i=0;i<10;i++)frame();check(d.image_index==0 && !d.transition_busy);
 keys=1;run(5);keys=0;run(150);frame();check(!d.transition_busy);
 d.reset=1;tick();d.reset=0;tick();check(d.image_index==0 && d.fade_level==32 && !d.transition_busy);
 std::cout<<"PASS: full fade ramp, black-only switch, blank-only updates, queued keys, hold/debounce, auto dwell, reset\n";
}
