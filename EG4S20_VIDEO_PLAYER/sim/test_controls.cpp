#include "Vslideshow_controls.h"
#include "verilated.h"
#include <stdexcept>
#include <iostream>
double sc_time_stamp(){return 0;}
int main(){
 Vslideshow_controls d; unsigned keys=0;
 auto tick=[&](){d.clk=0;d.key_col=d.key_row==7 ? (15^keys):15;d.eval();d.clk=1;d.eval();};
 auto run=[&](int n){while(n--)tick();};
 auto check=[&](bool ok){if(!ok)throw std::runtime_error("controls assertion failed");};
 auto frame=[&](){d.frame_end=1;tick();d.frame_end=0;tick();};
 auto press=[&](unsigned k){keys=k;run(150);keys=0;run(150);};
 d.reset=1;d.ready=0;d.frame_end=0;run(3);d.reset=0;run(20);
 press(2);frame();check(d.image_index==0); // Ignore navigation before load.
 d.ready=1;press(1);check(d.image_index==0);frame();check(d.image_index==2);
 keys=2;run(150);frame();check(d.image_index==0);run(150);frame();check(d.image_index==0);
 keys=0;run(150);press(2);check(d.image_index==0);frame();check(d.image_index==1);
 press(4);check(d.auto_mode);frame();frame();frame();check(d.image_index==1);
 frame();check(d.image_index==2); // Auto request commits at the next blank.
 press(4);check(!d.auto_mode);frame();auto held=d.image_index;
 for(int i=0;i<10;i++)frame();check(d.image_index==held);
 keys=1;run(5);keys=0;run(150);frame();check(d.image_index==held);
 std::cout<<"PASS controls: debounce, hold, wrap, frame boundary, auto/manual, not-ready\n";
}
