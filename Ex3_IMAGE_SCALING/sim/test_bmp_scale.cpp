#include "Vbmp_scale_stream.h"
#include "verilated.h"
#include <vector>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <cstdint>
double sc_time_stamp(){return 0;}
unsigned u32(const std::vector<unsigned char>&v,int i){return v[i]|(v[i+1]<<8)|(v[i+2]<<16)|(unsigned(v[i+3])<<24);}
void run(std::vector<unsigned char> bytes,bool bad=false){
 Vbmp_scale_stream d;
 auto tick=[&](){d.clk=0;d.eval();d.clk=1;d.eval();};
 d.reset=1;d.byte_valid=0;d.pixel_ready=0;tick();tick();d.reset=0;
 unsigned w=u32(bytes,18),h=u32(bytes,22),offset=u32(bytes,10);
 unsigned dw=(uint64_t(w)*480>=uint64_t(h)*640)?640:w*480/h;
 unsigned dh=dw==640?h*640/w:480;
 unsigned left=(640-dw)/2,bottom=(480-dh)/2,stride=(w*3+3)&~3u;
 unsigned input=0,output=0;
 bool held=false;unsigned last=0;
 for(unsigned t=0;t<15000000;t++){
  d.clk=0;d.pixel_ready=t%7!=0 && t%13!=0;
  d.byte_valid=input<bytes.size() && t%3!=0;
  d.byte_in=input<bytes.size()?bytes[input]:0;d.eval();
  if(held && (!d.pixel_valid || d.pixel!=last))throw std::runtime_error("valid/data changed under backpressure");
  held=d.pixel_valid&&!d.pixel_ready;last=d.pixel;
  bool consumed=d.byte_valid&&d.byte_ready;
  if(d.pixel_valid&&d.pixel_ready){
   unsigned x=output%640,y=output/640,expected=0;
   if(x>=left&&x<left+dw&&y>=bottom&&y<bottom+dh){
    unsigned sx=(x-left)*w/dw,sy=(y-bottom)*h/dh;
    unsigned pos=offset+sy*stride+sx*3;
    expected=((bytes[pos+2]>>3)<<11)|((bytes[pos+1]>>2)<<5)|(bytes[pos]>>3);
   }
   if(d.pixel!=expected){std::cerr<<w<<"x"<<h<<" pixel "<<x<<","<<y<<" got="<<d.pixel<<" expected="<<expected<<"\n";throw std::runtime_error("pixel mismatch");}
   output++;
  }
  d.clk=1;d.eval();if(consumed)input++;
  if(d.error){if(bad)return;throw std::runtime_error("unexpected parser error");}
  if(d.frame_done){
   if(bad||output!=307200||input!=bytes.size()||d.sector_count!=(bytes.size()+511)/512)throw std::runtime_error("length/count mismatch");
   std::cout<<"PASS "<<w<<"x"<<h<<" -> "<<dw<<"x"<<dh<<", 307200 pixels, stalls/padding\n";return;
  }
 }
 throw std::runtime_error("timeout");
}
std::vector<unsigned char> make(unsigned w,unsigned h,unsigned offset=54){
 unsigned stride=(w*3+3)&~3u;std::vector<unsigned char>v(offset+stride*h,0);
 auto put=[&](int i,unsigned n){for(int k=0;k<4;k++)v[i+k]=(n>>(k*8))&255;};
 v[0]='B';v[1]='M';put(2,v.size());put(10,offset);put(14,40);put(18,w);put(22,h);v[26]=1;v[28]=24;
 for(unsigned y=0;y<h;y++)for(unsigned x=0;x<w;x++){unsigned p=offset+y*stride+x*3;v[p]=x*7+y;v[p+1]=y*3+x;v[p+2]=x+y*5;}
 return v;
}
int main(){try{
 for(auto size:std::vector<std::pair<unsigned,unsigned>>{{320,240},{800,600},{1280,720},{480,800},{641,481},{640,480},{1,1},{100,100}})run(make(size.first,size.second));
 run(make(317,249,122));
 auto bad=make(10,10);bad[28]=32;run(bad,true);bad=make(10,10);bad[30]=1;run(bad,true);
 for(const char* name:{"F:/S320240.BMP","F:/S800600.BMP","F:/S1280720.BMP","F:/S480800.BMP","F:/S641481.BMP"}){
  std::ifstream f(name,std::ios::binary);if(!f)throw std::runtime_error("test card not connected");
  run(std::vector<unsigned char>((std::istreambuf_iterator<char>(f)),{}));
 }
}catch(const std::exception&e){std::cerr<<e.what()<<"\n";return 1;}}
