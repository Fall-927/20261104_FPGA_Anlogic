#include "Vav15_unpack.h"
#include "verilated.h"
#ifdef NDEBUG
#undef NDEBUG
#endif
#include <cassert>
#include <cstdint>
#include <iostream>
double sc_time_stamp(){return 0;}
int main(){
 Vav15_unpack d;d.clk=0;d.reset=1;d.word_ready=1;d.data_valid=0;
 auto tick=[&](){d.clk=0;d.eval();d.clk=1;d.eval();};
 tick();d.reset=0;tick();
 uint8_t h[512]={65,86,49,53,1,0,0,0,160,0,120,0,15,0,2,0,128,187};
 h[20]=2;h[25]=150;h[29]=50;
 for(auto b:h){assert(d.data_ready);d.data_byte=b;d.data_valid=1;tick();}
 d.data_valid=0;tick();assert(d.header_done&&!d.error&&d.frame_count==2&&d.sector_count==201);
 for(int i=0;i<102400;i++){
  // Pause between bytes and ensure the output remains ordered.
  if(i%17==0){d.data_valid=0;d.word_ready=0;tick();assert(!d.data_ready);d.word_ready=1;tick();}
  d.data_valid=1;d.data_byte=uint8_t(i);tick();assert(!d.error);
  assert(bool(d.word_valid)==bool(i&1));
  if(i&1)assert(d.word_data==uint16_t((uint8_t(i)<<8)|uint8_t(i-1)));
 }
 d.data_valid=0;tick();assert(!d.data_ready);
 d.reset=1;tick();d.reset=0;tick();d.data_valid=1;d.data_byte=0;tick();assert(d.error);
 std::cout<<"PASS AV15 header, 51200 words, stalls, endian order, bad magic\n";
}
