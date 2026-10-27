// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vsd_bmp_fixed_lba_reader.h for the primary calling header

#include "Vsd_bmp_fixed_lba_reader__pch.h"

void Vsd_bmp_fixed_lba_reader___024root___ctor_var_reset(Vsd_bmp_fixed_lba_reader___024root* vlSelf);

Vsd_bmp_fixed_lba_reader___024root::Vsd_bmp_fixed_lba_reader___024root(Vsd_bmp_fixed_lba_reader__Syms* symsp, const char* namep)
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
    Vsd_bmp_fixed_lba_reader___024root___ctor_var_reset(this);
}

void Vsd_bmp_fixed_lba_reader___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vsd_bmp_fixed_lba_reader___024root::~Vsd_bmp_fixed_lba_reader___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
