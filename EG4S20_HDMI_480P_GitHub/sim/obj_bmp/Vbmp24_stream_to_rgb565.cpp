// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vbmp24_stream_to_rgb565__pch.h"

//============================================================
// Constructors

Vbmp24_stream_to_rgb565::Vbmp24_stream_to_rgb565(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vbmp24_stream_to_rgb565__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , reset{vlSymsp->TOP.reset}
    , start{vlSymsp->TOP.start}
    , byte_in{vlSymsp->TOP.byte_in}
    , byte_valid{vlSymsp->TOP.byte_valid}
    , active{vlSymsp->TOP.active}
    , frame_done{vlSymsp->TOP.frame_done}
    , format_error{vlSymsp->TOP.format_error}
    , pixel_valid{vlSymsp->TOP.pixel_valid}
    , pixel_rgb565{vlSymsp->TOP.pixel_rgb565}
    , pixel_addr{vlSymsp->TOP.pixel_addr}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vbmp24_stream_to_rgb565::Vbmp24_stream_to_rgb565(const char* _vcname__)
    : Vbmp24_stream_to_rgb565(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vbmp24_stream_to_rgb565::~Vbmp24_stream_to_rgb565() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vbmp24_stream_to_rgb565___024root___eval_debug_assertions(Vbmp24_stream_to_rgb565___024root* vlSelf);
#endif  // VL_DEBUG
void Vbmp24_stream_to_rgb565___024root___eval_static(Vbmp24_stream_to_rgb565___024root* vlSelf);
void Vbmp24_stream_to_rgb565___024root___eval_initial(Vbmp24_stream_to_rgb565___024root* vlSelf);
void Vbmp24_stream_to_rgb565___024root___eval_settle(Vbmp24_stream_to_rgb565___024root* vlSelf);
void Vbmp24_stream_to_rgb565___024root___eval(Vbmp24_stream_to_rgb565___024root* vlSelf);

void Vbmp24_stream_to_rgb565::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vbmp24_stream_to_rgb565::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vbmp24_stream_to_rgb565___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vbmp24_stream_to_rgb565___024root___eval_static(&(vlSymsp->TOP));
        Vbmp24_stream_to_rgb565___024root___eval_initial(&(vlSymsp->TOP));
        Vbmp24_stream_to_rgb565___024root___eval_settle(&(vlSymsp->TOP));
        vlSymsp->__Vm_didInit = true;
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vbmp24_stream_to_rgb565___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vbmp24_stream_to_rgb565::eventsPending() { return false; }

uint64_t Vbmp24_stream_to_rgb565::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vbmp24_stream_to_rgb565::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vbmp24_stream_to_rgb565___024root___eval_final(Vbmp24_stream_to_rgb565___024root* vlSelf);

VL_ATTR_COLD void Vbmp24_stream_to_rgb565::final() {
    contextp()->executingFinal(true);
    Vbmp24_stream_to_rgb565___024root___eval_final(&(vlSymsp->TOP));
    contextp()->executingFinal(false);
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vbmp24_stream_to_rgb565::hierName() const { return vlSymsp->name(); }
const char* Vbmp24_stream_to_rgb565::modelName() const { return "Vbmp24_stream_to_rgb565"; }
unsigned Vbmp24_stream_to_rgb565::threads() const { return 1; }
void Vbmp24_stream_to_rgb565::prepareClone() const { contextp()->prepareClone(); }
void Vbmp24_stream_to_rgb565::atClone() const {
    contextp()->threadPoolpOnClone();
}
