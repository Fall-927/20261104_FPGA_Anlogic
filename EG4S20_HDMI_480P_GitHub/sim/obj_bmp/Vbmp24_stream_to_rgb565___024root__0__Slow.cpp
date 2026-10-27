// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vbmp24_stream_to_rgb565.h for the primary calling header

#include "Vbmp24_stream_to_rgb565__pch.h"

VL_ATTR_COLD void Vbmp24_stream_to_rgb565___024root___eval_static(Vbmp24_stream_to_rgb565___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___eval_static\n"); );
    Vbmp24_stream_to_rgb565__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vtrigprevexpr___TOP__clk__0 = vlSelfRef.clk;
    vlSelfRef.__Vtrigprevexpr___TOP__reset__0 = vlSelfRef.reset;
}

VL_ATTR_COLD void Vbmp24_stream_to_rgb565___024root___eval_initial(Vbmp24_stream_to_rgb565___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___eval_initial\n"); );
    Vbmp24_stream_to_rgb565__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vbmp24_stream_to_rgb565___024root___eval_final(Vbmp24_stream_to_rgb565___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___eval_final\n"); );
    Vbmp24_stream_to_rgb565__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vbmp24_stream_to_rgb565___024root___eval_settle(Vbmp24_stream_to_rgb565___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___eval_settle\n"); );
    Vbmp24_stream_to_rgb565__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

bool Vbmp24_stream_to_rgb565___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vbmp24_stream_to_rgb565___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vbmp24_stream_to_rgb565___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(posedge reset)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vbmp24_stream_to_rgb565___024root___ctor_var_reset(Vbmp24_stream_to_rgb565___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___ctor_var_reset\n"); );
    Vbmp24_stream_to_rgb565__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->clk = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16707436170211756652ull);
    vlSelf->reset = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9928399931838511862ull);
    vlSelf->start = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9867861323841650631ull);
    vlSelf->byte_in = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 6945550168992394540ull);
    vlSelf->byte_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6716841169170888791ull);
    vlSelf->active = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12797771265061833892ull);
    vlSelf->frame_done = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 18047452146504048636ull);
    vlSelf->format_error = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10423270270267341676ull);
    vlSelf->pixel_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16257453768384203186ull);
    vlSelf->pixel_addr = VL_SCOPED_RAND_RESET_I(19, __VscopeHash, 7887535891173370020ull);
    vlSelf->pixel_rgb565 = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 11527377371647330717ull);
    vlSelf->bmp24_stream_to_rgb565__DOT__pos = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 12907544156747050395ull);
    vlSelf->bmp24_stream_to_rgb565__DOT__offset = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11449501629927497502ull);
    vlSelf->bmp24_stream_to_rgb565__DOT__blue = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 10251087316377661746ull);
    vlSelf->bmp24_stream_to_rgb565__DOT__green = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 4478445214618713635ull);
    vlSelf->bmp24_stream_to_rgb565__DOT__phase = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 11479905773100565874ull);
    vlSelf->bmp24_stream_to_rgb565__DOT__x = VL_SCOPED_RAND_RESET_I(10, __VscopeHash, 16076008807805629572ull);
    vlSelf->bmp24_stream_to_rgb565__DOT__y = VL_SCOPED_RAND_RESET_I(10, __VscopeHash, 17072096111404439608ull);
    vlSelf->bmp24_stream_to_rgb565__DOT__row_base = VL_SCOPED_RAND_RESET_I(19, __VscopeHash, 2465811477286690984ull);
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__reset__0 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
}
