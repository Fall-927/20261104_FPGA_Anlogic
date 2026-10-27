// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vbmp24_stream_to_rgb565.h for the primary calling header

#ifndef VERILATED_VBMP24_STREAM_TO_RGB565___024ROOT_H_
#define VERILATED_VBMP24_STREAM_TO_RGB565___024ROOT_H_  // guard

#include "verilated.h"


class Vbmp24_stream_to_rgb565__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vbmp24_stream_to_rgb565___024root final {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(reset,0,0);
    VL_IN8(start,0,0);
    VL_IN8(byte_in,7,0);
    VL_IN8(byte_valid,0,0);
    VL_OUT8(active,0,0);
    VL_OUT8(frame_done,0,0);
    VL_OUT8(format_error,0,0);
    VL_OUT8(pixel_valid,0,0);
    CData/*7:0*/ bmp24_stream_to_rgb565__DOT__blue;
    CData/*7:0*/ bmp24_stream_to_rgb565__DOT__green;
    CData/*1:0*/ bmp24_stream_to_rgb565__DOT__phase;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__reset__0;
    CData/*0:0*/ __VactPhaseResult;
    CData/*0:0*/ __VnbaPhaseResult;
    VL_OUT16(pixel_rgb565,15,0);
    SData/*9:0*/ bmp24_stream_to_rgb565__DOT__x;
    SData/*9:0*/ bmp24_stream_to_rgb565__DOT__y;
    VL_OUT(pixel_addr,18,0);
    IData/*31:0*/ bmp24_stream_to_rgb565__DOT__pos;
    IData/*31:0*/ bmp24_stream_to_rgb565__DOT__offset;
    IData/*18:0*/ bmp24_stream_to_rgb565__DOT__row_base;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vbmp24_stream_to_rgb565__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vbmp24_stream_to_rgb565___024root(Vbmp24_stream_to_rgb565__Syms* symsp, const char* namep);
    ~Vbmp24_stream_to_rgb565___024root();
    VL_UNCOPYABLE(Vbmp24_stream_to_rgb565___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
