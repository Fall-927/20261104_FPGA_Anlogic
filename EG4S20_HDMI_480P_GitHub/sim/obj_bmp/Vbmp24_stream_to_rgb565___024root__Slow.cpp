// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vbmp24_stream_to_rgb565.h for the primary calling header

#include "Vbmp24_stream_to_rgb565__pch.h"

void Vbmp24_stream_to_rgb565___024root___ctor_var_reset(Vbmp24_stream_to_rgb565___024root* vlSelf);

Vbmp24_stream_to_rgb565___024root::Vbmp24_stream_to_rgb565___024root(Vbmp24_stream_to_rgb565__Syms* symsp, const char* namep)
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
    Vbmp24_stream_to_rgb565___024root___ctor_var_reset(this);
}

void Vbmp24_stream_to_rgb565___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vbmp24_stream_to_rgb565___024root::~Vbmp24_stream_to_rgb565___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
