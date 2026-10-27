// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vsd_bmp_fixed_lba_reader.h for the primary calling header

#ifndef VERILATED_VSD_BMP_FIXED_LBA_READER___024ROOT_H_
#define VERILATED_VSD_BMP_FIXED_LBA_READER___024ROOT_H_  // guard

#include "verilated.h"


class Vsd_bmp_fixed_lba_reader__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vsd_bmp_fixed_lba_reader___024root final {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(reset,0,0);
    VL_IN8(sd_miso,0,0);
    VL_OUT8(sd_cs,0,0);
    VL_OUT8(sd_sck,0,0);
    VL_OUT8(sd_mosi,0,0);
    VL_OUT8(data_byte,7,0);
    VL_OUT8(data_valid,0,0);
    VL_OUT8(busy,0,0);
    VL_OUT8(done,0,0);
    VL_OUT8(error,0,0);
    CData/*7:0*/ sd_bmp_fixed_lba_reader__DOT__tx;
    CData/*7:0*/ sd_bmp_fixed_lba_reader__DOT__rx;
    CData/*0:0*/ sd_bmp_fixed_lba_reader__DOT__launch;
    CData/*0:0*/ sd_bmp_fixed_lba_reader__DOT__slow;
    CData/*0:0*/ sd_bmp_fixed_lba_reader__DOT__byte_busy;
    CData/*0:0*/ sd_bmp_fixed_lba_reader__DOT__byte_done;
    CData/*4:0*/ sd_bmp_fixed_lba_reader__DOT__state;
    CData/*4:0*/ sd_bmp_fixed_lba_reader__DOT__after_byte;
    CData/*2:0*/ sd_bmp_fixed_lba_reader__DOT__cmd_byte;
    CData/*2:0*/ sd_bmp_fixed_lba_reader__DOT__extra;
    CData/*2:0*/ sd_bmp_fixed_lba_reader__DOT__op;
    CData/*7:0*/ sd_bmp_fixed_lba_reader__DOT__response;
    CData/*7:0*/ sd_bmp_fixed_lba_reader__DOT__spi__DOT__shift;
    CData/*6:0*/ sd_bmp_fixed_lba_reader__DOT__spi__DOT__divider;
    CData/*2:0*/ sd_bmp_fixed_lba_reader__DOT__spi__DOT__bitnum;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__reset__0;
    CData/*0:0*/ __VactPhaseResult;
    CData/*0:0*/ __VnbaPhaseResult;
    SData/*15:0*/ sd_bmp_fixed_lba_reader__DOT__tries;
    SData/*9:0*/ sd_bmp_fixed_lba_reader__DOT__count;
    VL_OUT(sector,31,0);
    IData/*19:0*/ sd_bmp_fixed_lba_reader__DOT__timeout;
    IData/*31:0*/ sd_bmp_fixed_lba_reader__DOT__blocks;
    IData/*31:0*/ sd_bmp_fixed_lba_reader__DOT__power_wait;
    IData/*31:0*/ sd_bmp_fixed_lba_reader__DOT__tail;
    IData/*31:0*/ __VactIterCount;
    QData/*47:0*/ sd_bmp_fixed_lba_reader__DOT__command;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vsd_bmp_fixed_lba_reader__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vsd_bmp_fixed_lba_reader___024root(Vsd_bmp_fixed_lba_reader__Syms* symsp, const char* namep);
    ~Vsd_bmp_fixed_lba_reader___024root();
    VL_UNCOPYABLE(Vsd_bmp_fixed_lba_reader___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
