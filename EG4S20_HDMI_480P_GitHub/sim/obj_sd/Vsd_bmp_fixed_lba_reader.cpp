// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vsd_bmp_fixed_lba_reader__pch.h"

//============================================================
// Constructors

Vsd_bmp_fixed_lba_reader::Vsd_bmp_fixed_lba_reader(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vsd_bmp_fixed_lba_reader__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , reset{vlSymsp->TOP.reset}
    , sd_miso{vlSymsp->TOP.sd_miso}
    , sd_cs{vlSymsp->TOP.sd_cs}
    , sd_sck{vlSymsp->TOP.sd_sck}
    , sd_mosi{vlSymsp->TOP.sd_mosi}
    , data_byte{vlSymsp->TOP.data_byte}
    , data_valid{vlSymsp->TOP.data_valid}
    , busy{vlSymsp->TOP.busy}
    , done{vlSymsp->TOP.done}
    , error{vlSymsp->TOP.error}
    , sector{vlSymsp->TOP.sector}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vsd_bmp_fixed_lba_reader::Vsd_bmp_fixed_lba_reader(const char* _vcname__)
    : Vsd_bmp_fixed_lba_reader(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vsd_bmp_fixed_lba_reader::~Vsd_bmp_fixed_lba_reader() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vsd_bmp_fixed_lba_reader___024root___eval_debug_assertions(Vsd_bmp_fixed_lba_reader___024root* vlSelf);
#endif  // VL_DEBUG
void Vsd_bmp_fixed_lba_reader___024root___eval_static(Vsd_bmp_fixed_lba_reader___024root* vlSelf);
void Vsd_bmp_fixed_lba_reader___024root___eval_initial(Vsd_bmp_fixed_lba_reader___024root* vlSelf);
void Vsd_bmp_fixed_lba_reader___024root___eval_settle(Vsd_bmp_fixed_lba_reader___024root* vlSelf);
void Vsd_bmp_fixed_lba_reader___024root___eval(Vsd_bmp_fixed_lba_reader___024root* vlSelf);

void Vsd_bmp_fixed_lba_reader::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vsd_bmp_fixed_lba_reader::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vsd_bmp_fixed_lba_reader___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vsd_bmp_fixed_lba_reader___024root___eval_static(&(vlSymsp->TOP));
        Vsd_bmp_fixed_lba_reader___024root___eval_initial(&(vlSymsp->TOP));
        Vsd_bmp_fixed_lba_reader___024root___eval_settle(&(vlSymsp->TOP));
        vlSymsp->__Vm_didInit = true;
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vsd_bmp_fixed_lba_reader___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vsd_bmp_fixed_lba_reader::eventsPending() { return false; }

uint64_t Vsd_bmp_fixed_lba_reader::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vsd_bmp_fixed_lba_reader::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vsd_bmp_fixed_lba_reader___024root___eval_final(Vsd_bmp_fixed_lba_reader___024root* vlSelf);

VL_ATTR_COLD void Vsd_bmp_fixed_lba_reader::final() {
    contextp()->executingFinal(true);
    Vsd_bmp_fixed_lba_reader___024root___eval_final(&(vlSymsp->TOP));
    contextp()->executingFinal(false);
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vsd_bmp_fixed_lba_reader::hierName() const { return vlSymsp->name(); }
const char* Vsd_bmp_fixed_lba_reader::modelName() const { return "Vsd_bmp_fixed_lba_reader"; }
unsigned Vsd_bmp_fixed_lba_reader::threads() const { return 1; }
void Vsd_bmp_fixed_lba_reader::prepareClone() const { contextp()->prepareClone(); }
void Vsd_bmp_fixed_lba_reader::atClone() const {
    contextp()->threadPoolpOnClone();
}
