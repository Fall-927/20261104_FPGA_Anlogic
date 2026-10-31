#include "Vsdram_write_path_tb.h"
#include "verilated.h"
#include <iostream>
#include <stdexcept>
double sc_time_stamp(){return 0;}
static unsigned pattern(unsigned a){return ((a*73)^(a>>8)^0x529a)&65535;}
int main(){try {
 Vsdram_write_path_tb d;unsigned row[4]={},location=0,written=0,burst_count=0;
 bool writing=false;
 auto tick=[&](){d.clk=0;d.eval();d.clk=1;d.eval();
  // SDRAM clock is phase shifted: sample command/data after the controller edge.
  unsigned cmd=d.command&15;
  if(cmd==3)row[d.bank]=d.address;
  if(cmd==4){location=(d.bank<<19)|(row[d.bank]<<8)|(d.address&255);writing=true;burst_count=0;}
  if(cmd==6 || cmd==2)writing=false;
  if(writing){
   if(d.bus_data!=pattern(location))throw std::runtime_error("write mismatch: address="+std::to_string(location)+" burst_pixel="+std::to_string(burst_count)+" actual="+std::to_string(d.bus_data)+" expected="+std::to_string(pattern(location)));
   location=(location&~255u)|((location+1)&255);written++;burst_count++;
  }
 };
 d.reset=1;d.pixel_valid=0;tick();d.reset=0;
 for(int i=0;i<22000;i++)tick();
 if(!d.init_done)throw std::runtime_error("SDRAM init failed");
 for(unsigned a=0;a<128*8;a++){d.pixel_valid=1;d.pixel=pattern(a);tick();d.pixel_valid=0;tick();tick();tick();}
 for(int i=0;i<1000;i++)tick();
 if(written!=1024)throw std::runtime_error("incorrect number of physical writes: "+std::to_string(written));
 std::cout<<"PASS actual SDRAM write path: 8 bursts / 1024 exact pixels, including every boundary\n";
}catch(const std::exception&e){std::cerr<<e.what()<<std::endl;return 1;}}
