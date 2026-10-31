#include "Vsd_av_reader.h"
#include "Vsd_av_reader___024root.h"
#include "verilated.h"
#include <iostream>
#include <stdexcept>
double sc_time_stamp(){return 0;}
// Seed a legal post-token FETCH state. Exercise the actual SPI byte master,
// not card initialization or a complete SD card model. MISO=1 means 0xff data.
int main(){try{
 for(unsigned offset: {0u,1u,255u,510u,511u}){
  Vsd_av_reader d;
  auto tick=[&](){d.clk=0;d.eval();d.clk=1;d.eval();};
  d.reset=1;d.stop_request=0;d.data_ready=0;d.sd_miso=1;
  d.start_lba=251744;d.sector_count=17239;tick();tick();d.reset=0;
  d.rootp->sd_av_reader__DOT__state=16;
  d.rootp->sd_av_reader__DOT__count=offset;
  d.rootp->sd_av_reader__DOT__slow=0;
  d.sd_cs=0;
  d.rootp->sd_av_reader__DOT__sd_cs=0;
  d.stop_request=1;
  unsigned clocks=0;
  for(unsigned t=0;t<40000&&!d.stopped;t++){
   bool before=d.sd_sck;tick();if(!before&&d.sd_sck)clocks++;
   if(d.data_valid)throw std::runtime_error("drained data reached consumer");
  }
  if(!d.stopped||!d.sd_cs||d.sd_sck||d.error)throw std::runtime_error("stop handshake");
  if(clocks!=(512-offset+3)*8)throw std::runtime_error("must drain data, 2 CRC, trailing byte");
  for(int i=0;i<100;i++){tick();if(!d.stopped||!d.sd_cs||d.sd_sck)throw std::runtime_error("stop not held");}
  d.reset=1;tick();if(d.stopped)throw std::runtime_error("reset stop flag");
 }
 std::cout<<"PASS safe stop: 5 sector offsets, FIFO backpressure, CRC, trailing clocks, reset\n";
}catch(const std::exception&e){std::cerr<<e.what()<<"\n";return 1;}}
