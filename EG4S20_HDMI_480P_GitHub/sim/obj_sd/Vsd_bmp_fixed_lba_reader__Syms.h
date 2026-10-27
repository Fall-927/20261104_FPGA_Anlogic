// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VSD_BMP_FIXED_LBA_READER__SYMS_H_
#define VERILATED_VSD_BMP_FIXED_LBA_READER__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vsd_bmp_fixed_lba_reader.h"

// INCLUDE MODULE CLASSES
#include "Vsd_bmp_fixed_lba_reader___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES) Vsd_bmp_fixed_lba_reader__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vsd_bmp_fixed_lba_reader* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vsd_bmp_fixed_lba_reader___024root TOP;

    // CONSTRUCTORS
    Vsd_bmp_fixed_lba_reader__Syms(VerilatedContext* contextp, const char* namep, Vsd_bmp_fixed_lba_reader* modelp);
    ~Vsd_bmp_fixed_lba_reader__Syms();

    // METHODS
    const char* name() const { return TOP.vlNamep; }
};

#endif  // guard
