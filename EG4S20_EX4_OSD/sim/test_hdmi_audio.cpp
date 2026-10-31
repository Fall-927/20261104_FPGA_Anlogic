#include "Vhdmi_audio_tx.h"
#include "verilated.h"
#include <array>
#include <cmath>
#include <cstdint>
#include <deque>
#include <iostream>
#include <stdexcept>
double sc_time_stamp(){return 0;}
static const unsigned terc[16]={0x29c,0x263,0x2e4,0x2e2,0x171,0x11e,0x18e,0x13c,0x2cc,0x139,0x19c,0x2c6,0x28e,0x271,0x163,0x2c3};
static const unsigned control[4]={0x354,0xab,0x154,0x2ab};
static void require(bool ok,const char *message){if(!ok)throw std::runtime_error(message);}
static unsigned decode(unsigned word){for(unsigned i=0;i<16;i++)if(terc[i]==word)return i;throw std::runtime_error("invalid TERC4");}
static unsigned ecc(uint64_t bits,unsigned n){unsigned e=0;for(unsigned i=0;i<n;i++){bool q=(e^(bits>>i))&1;e=(e>>1)^(q?0x83:0);}return e;}
static unsigned video(unsigned data,int &disparity){
 unsigned count=0;for(int i=0;i<8;i++)count+=(data>>i)&1;
 bool xn=count>4||(count==4&&!(data&1));unsigned q=data&1;
 for(int i=1;i<8;i++)q|=((((q>>(i-1))^(data>>i))&1)^xn)<<i;
 bool q8=!xn;unsigned ones=0;for(int i=0;i<8;i++)ones+=(q>>i)&1;
 int balance=int(ones)*2-8;unsigned result;
 if(disparity==0||balance==0){result=(!q8<<9)|(q8<<8)|(q8?q:(q^255));disparity+=q8?balance:-balance;}
 else if((disparity>0&&balance>0)||(disparity<0&&balance<0)){result=512|(q8<<8)|(q^255);disparity+=-balance+(q8?2:0);}
 else {result=(q8<<8)|q;disparity+=balance-(q8?0:2);}
 return result;
}
int main(){try {
 Vhdmi_audio_tx d;d.clk=0;d.reset=1;d.play=0;d.x=0;d.y=0;d.hs=1;d.vs=1;d.de=0;d.eval();d.clk=1;d.eval();d.reset=0;
 std::deque<std::pair<int,unsigned>> expected;
 uint64_t sub[4]={};uint32_t head=0;unsigned generated=0,received=0,acr=0,avi=0,info=0;
 unsigned div=0,phase=0,frame=0;bool playing=false;int disparity[3]={};
 constexpr unsigned frames=62,total=frames*420000;
 for(unsigned t=0;t<total;t++){
  unsigned x=t%800,y=(t/800)%525,f=t/420000;
  bool play=f>=2&&f<61;
  bool hs=!(x>=656&&x<752),vs=!(y>=490&&y<492),de=x<640&&y<480;
  unsigned rgb[3]={(x*19+y*11)&255,(x*7+y*23)&255,(x*3+y*13)&255};
  d.clk=0;d.x=x;d.y=y;d.hs=hs;d.vs=vs;d.de=de;d.play=play;
  d.blue=rgb[0];d.green=rgb[1];d.red=rgb[2];d.eval();
  require(bool(d.sample_tick)==(div==524),"sample enable cadence");
  if(div==524){
   int s=playing&&play?int(std::round(4096*std::sin(2*3.14159265358979323846*phase/48))):0;
   expected.push_back({s,frame});generated++;frame=(frame+1)%192;
   phase=playing&&play?(phase+1)%48:0;div=0;
  }else div++;
  if(x==0&&y==0)playing=play;
  d.clk=1;d.eval();require(!d.audio_overflow,"audio FIFO overflow");
  unsigned word[3]={d.symbol_b,d.symbol_g,d.symbol_r};
  if(de){for(int c=0;c<3;c++)require(word[c]==video(rgb[c],disparity[c]),"visible RGB timing/coding changed");}
  else {
   disparity[0]=disparity[1]=disparity[2]=0;
   if(x>=654&&x<750){
    unsigned pc=(x-654)%32,b=decode(word[0]),g=decode(word[1]),r=decode(word[2]);
    require((b&3)==unsigned((vs<<1)|hs)&&(b&8),"island sync fields");
    if(pc==0){head=0;for(auto &s:sub)s=0;}
    head|=((b>>2)&1)<<pc;
    for(unsigned k=0;k<4;k++)sub[k]|=uint64_t((g>>k)&1)<<(pc*2),sub[k]|=uint64_t((r>>k)&1)<<(pc*2+1);
    if(pc==31){
     require((head>>24)==ecc(head,24),"header BCH");
     for(auto s:sub)require((s>>56)==ecc(s,56),"subpacket BCH");
     unsigned type=head&255;
     if(type==2){
      require((head&0x0ff000)==0,"audio layout/reserved bits");
      for(unsigned k=0;k<4;k++)if(head&(1u<<(8+k))){
       require(!expected.empty(),"sample duplication");auto exp=expected.front();expected.pop_front();received++;
       uint32_t l=sub[k]&0xffffff,rw=(sub[k]>>24)&0xffffff;
       if(l!=rw||l!=((uint32_t(exp.first)&65535)<<8))throw std::runtime_error("PCM mismatch sample "+std::to_string(received)+" actual "+std::to_string(int16_t(l>>8))+" expected "+std::to_string(exp.first));
       unsigned flags=(sub[k]>>48)&255;
       uint64_t left_status=0xd202100004ULL,right_status=0xd202200004ULL;
       unsigned cl=exp.second<40?(left_status>>exp.second)&1:0,cr=exp.second<40?(right_status>>exp.second)&1:0;
       unsigned parity=0;for(unsigned z=0;z<24;z++)parity^=(l>>z)&1;
       require(flags==((parity^cr)<<7|cr<<6|(parity^cl)<<3|cl<<2),"IEC60958 status/parity");
       require(bool(head&(1u<<(20+k)))==(exp.second==0),"IEC block-start bit");
      }
     }else if(type==1){
      acr++;for(auto s:sub){unsigned cts=((s>>8)&15)<<16|((s>>16)&255)<<8|((s>>24)&255);
       unsigned n=((s>>32)&15)<<16|((s>>40)&255)<<8|((s>>48)&255);
       require(n==6144&&cts==25200,"ACR N/CTS");require(25200000ull*n==48000ull*128*cts,"ACR sample frequency");}
     }else if(type==0x82||type==0x84){
      unsigned sum=(head&255)+((head>>8)&255)+((head>>16)&255);
      for(auto s:sub)for(int i=0;i<7;i++)sum+=(s>>(i*8))&255;
      require((sum&255)==0,"InfoFrame checksum");
      if(type==0x82){avi++;require((head&0xffffff)==0x0d0282,"AVI header");}
      else {info++;require((head&0xffffff)==0x0a0184&&(sub[0]&65535)==0x170,"stereo audio infoframe");}
     }else require(type==0,"unknown packet type");
    }
   }else if((x>=652&&x<654)||(x>=750&&x<752)){
    require(word[0]==terc[12|(vs<<1)|hs]&&word[1]==0x133&&word[2]==0x133,"data guard bands");
   }else if(x>=798&&(y<479||y==524)){
    require(word[0]==0x2cc&&word[1]==0x133&&word[2]==0x2cc,"video guard bands");
   }else {
    bool dip=x>=644&&x<652,vp=x>=790&&x<798&&(y<479||y==524);
    require(word[0]==control[(vs<<1)|hs]&&word[1]==control[dip||vp]&&word[2]==control[dip],"control/preamble timing");
   }
  }
 }
 require(generated==frames*800&&generated-received==expected.size()&&expected.size()<5,"48kHz rate / drain");
 require(avi==frames&&info==frames&&acr==frames*17,"metadata cadence");
 std::cout<<"PASS HDMI audio: "<<generated<<" samples, "<<received<<" decoded, 48kHz/1kHz stereo; BCH, IEC parity, InfoFrames, N/CTS, guards, preambles and RGB checked over "<<frames<<" frames\n";
}catch(const std::exception &e){std::cerr<<e.what()<<std::endl;return 1;}}
