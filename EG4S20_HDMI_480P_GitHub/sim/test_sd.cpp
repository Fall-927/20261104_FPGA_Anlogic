#include "Vsd_bmp_fixed_lba_reader.h"
#include "verilated.h"
#include <deque>
#include <vector>
#include <iostream>
#include <stdexcept>
double sc_time_stamp(){return 0;}
int main(){
 Vsd_bmp_fixed_lba_reader d;
 std::deque<unsigned> out;
 std::vector<unsigned> cmd,seen;
 unsigned bits=0,in=0,send=255,received=0,reads=0;
 bool old_sck=0;
 auto byte=[&](unsigned b){
  if(cmd.empty() && (b&0xc0)!=0x40) return;
  cmd.push_back(b);
  if(cmd.size()!=6) return;
  unsigned op=cmd[0]&63;
  unsigned arg=(cmd[1]<<24)|(cmd[2]<<16)|(cmd[3]<<8)|cmd[4];
  seen.push_back(op);
  auto q=[&](unsigned x){out.push_back(x);};
  q(255);
  if(op==0){if(cmd[5]!=0x95)throw std::runtime_error("CMD0 CRC");q(1);}
  else if(op==8){if(arg!=0x1aa || cmd[5]!=0x87)throw std::runtime_error("CMD8");q(1);q(0);q(0);q(1);q(0xaa);}
  else if(op==55) q(1);
  else if(op==41){if(arg!=0x40000000)throw std::runtime_error("ACMD41 HCS");q(0);}
  else if(op==58){q(0);q(0xc0);q(0xff);q(0x80);q(0);}
  else if(op==17){
   if(arg!=2048+reads)throw std::runtime_error("CMD17 address");
   reads++;q(0);q(255);q(0xfe);
   for(unsigned i=0;i<512;i++)q(i&255);
   q(0x12);q(0x34);
  }else throw std::runtime_error("unexpected command");
  cmd.clear();
 };
 auto tick=[&](){
  d.clk=0;d.eval();d.clk=1;d.eval();
  if(d.sd_cs){bits=0;in=0;send=255;cmd.clear();out.clear();d.sd_miso=1;}
  else {
   if(!old_sck && d.sd_sck){
    in=(in<<1)|d.sd_mosi;bits++;
    if(bits==8){byte(in&255);in=0;bits=0;}
   }
   if(old_sck && !d.sd_sck){
    if(bits==0){send=out.empty()?255:out.front();if(!out.empty())out.pop_front();}
    d.sd_miso=(send>>(7-bits))&1;
   }
  }
  old_sck=d.sd_sck;
  if(d.data_valid){if(d.data_byte!=(received&255))throw std::runtime_error("data/token/CRC alignment");received++;}
 };
 d.reset=1;d.sd_miso=1;tick();d.reset=0;
 for(unsigned i=0;i<3000000 && !d.done && !d.error;i++)tick();
 if(!d.done || d.error || received!=1024 || reads!=2)
  throw std::runtime_error("SD transfer incomplete");
 if(seen!=std::vector<unsigned>({0,8,55,41,58,17,17}))throw std::runtime_error("initialization sequence");
 std::cout<<"PASS: mode-0 SDHC init, CMD17 arguments, 2 sectors / 1024 bytes, token/CRC exclusion\n";
}
