// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VBMP24_STREAM_TO_RGB565__SYMS_H_
#define VERILATED_VBMP24_STREAM_TO_RGB565__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vbmp24_stream_to_rgb565.h"

// INCLUDE MODULE CLASSES
#include "Vbmp24_stream_to_rgb565___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES) Vbmp24_stream_to_rgb565__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vbmp24_stream_to_rgb565* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vbmp24_stream_to_rgb565___024root TOP;

    // CONSTRUCTORS
    Vbmp24_stream_to_rgb565__Syms(VerilatedContext* contextp, const char* namep, Vbmp24_stream_to_rgb565* modelp);
    ~Vbmp24_stream_to_rgb565__Syms();

    // METHODS
    const char* name() const { return TOP.vlNamep; }
};

#endif  // guard
