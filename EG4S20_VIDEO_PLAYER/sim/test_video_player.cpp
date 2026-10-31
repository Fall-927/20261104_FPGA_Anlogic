#include "Vvideo_player_tb.h"
#include "verilated.h"
#include <cstdint>
#include <iostream>
#include <stdexcept>
#include <string>
double sc_time_stamp(){return 0;}
int main(int argc,char**argv){try{
 bool pause_test=argc>1&&std::string(argv[1])=="--pause";
 bool switch_test=argc>1&&std::string(argv[1])=="--switch";
 Vvideo_player_tb d;d.clk=0;d.reset=1;d.key_col=15;
 auto tick=[&](){d.clk=0;d.eval();d.clk=1;d.eval();};
 for(int i=0;i<10;i++)tick();d.reset=0;
 uint64_t pixels=0,samples=0;unsigned display_frames=0;
 bool started=false,saw_pause=false,saw_restart=false;
 for(unsigned t=0;t<110000000;t++){
  bool press_pause=pause_test&&((t>=55000000&&t<57500000)||(t>=60000000&&t<62500000));
  bool press_next=switch_test&&t>=55000000&&t<57500000;
  d.key_col=(d.key_row==7)?(press_pause?11:press_next?13:15):15;
  d.clk=0;d.eval();
  if(d.fail)throw std::runtime_error("player fail at t="+std::to_string(t)+" packet="+std::to_string(d.packet_number)+" xy="+std::to_string(d.x)+","+std::to_string(d.y)+" ready="+std::to_string(d.ready)+" released="+std::to_string(d.released)+" empty="+std::to_string(d.video_empty)+","+std::to_string(d.audio_empty)+" pcm_phase="+std::to_string(d.pcm_phase));
  if(d.playing){
   started=true;
   if(d.paused)saw_pause=true;
   if(d.x==0&&d.y==0)display_frames++;
   if(d.de){
    unsigned expected=(d.y/2)*320+(d.x/2)+d.packet_number*1000;
    if(d.rgb!=uint16_t(expected))throw std::runtime_error("pixel mismatch xy="+std::to_string(d.x)+","+std::to_string(d.y)+" packet="+std::to_string(d.packet_number)+" actual="+std::to_string(d.rgb)+" expected="+std::to_string(expected));
    pixels++;
   }
   if(d.sample_tick && !d.paused){
    unsigned loop_sample=samples%38400;
    if(d.pcm_left!=uint16_t(loop_sample) || d.pcm_right!=uint16_t(65535-loop_sample))
     throw std::runtime_error("PCM mismatch at sample="+std::to_string(samples)+" actual="+std::to_string(d.pcm_left)+","+std::to_string(d.pcm_right));
    samples++;
   }
   if(samples==76800){
    if(pause_test&&!saw_pause)throw std::runtime_error("pause never activated");
    if(switch_test&&!saw_restart)throw std::runtime_error("switch never activated");
    std::cout<<"PASS HQ 320x240, two seamless loops, "<<pixels<<" checked pixels, "<<samples<<" stereo samples; pause="<<pause_test<<" switch="<<switch_test<<"\n";
    return 0;
   }
  }else if(started){
   if(switch_test&&!saw_restart){
    saw_restart=true;started=false;pixels=0;samples=0;display_frames=0;
    d.clk=1;d.eval();continue;
   }
   if(samples!=76800)
    throw std::runtime_error("wrong totals samples="+std::to_string(samples)+" pixels="+std::to_string(pixels));
   if(pause_test&&!saw_pause)throw std::runtime_error("pause never activated");
   if(switch_test&&!saw_restart)throw std::runtime_error("switch never activated");
   std::cout<<"PASS 8 AV packets, "<<pixels<<" exact scaled pixels, "<<samples<<" ordered stereo samples, slot wrap and EOF; pause="<<pause_test<<" switch="<<switch_test<<"\n";
   return 0;
  }
  d.clk=1;d.eval();
 }
 throw std::runtime_error("timeout frames="+std::to_string(display_frames));
}catch(const std::exception&e){std::cerr<<e.what()<<"\n";return 1;}}
