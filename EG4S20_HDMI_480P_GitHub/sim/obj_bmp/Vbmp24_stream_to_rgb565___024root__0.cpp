// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vbmp24_stream_to_rgb565.h for the primary calling header

#include "Vbmp24_stream_to_rgb565__pch.h"

void Vbmp24_stream_to_rgb565___024root___eval_triggers_vec__act(Vbmp24_stream_to_rgb565___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___eval_triggers_vec__act\n"); );
    Vbmp24_stream_to_rgb565__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                    ((((IData)(vlSelfRef.reset) 
                                                       & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__reset__0))) 
                                                      << 1U) 
                                                     | ((IData)(vlSelfRef.clk) 
                                                        & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__clk__0))))));
    vlSelfRef.__Vtrigprevexpr___TOP__clk__0 = vlSelfRef.clk;
    vlSelfRef.__Vtrigprevexpr___TOP__reset__0 = vlSelfRef.reset;
}

bool Vbmp24_stream_to_rgb565___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___trigger_anySet__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

void Vbmp24_stream_to_rgb565___024root___nba_sequent__TOP__0(Vbmp24_stream_to_rgb565___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___nba_sequent__TOP__0\n"); );
    Vbmp24_stream_to_rgb565__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __Vdly__active;
    __Vdly__active = 0;
    CData/*0:0*/ __Vdly__format_error;
    __Vdly__format_error = 0;
    IData/*31:0*/ __Vdly__bmp24_stream_to_rgb565__DOT__pos;
    __Vdly__bmp24_stream_to_rgb565__DOT__pos = 0;
    IData/*31:0*/ __Vdly__bmp24_stream_to_rgb565__DOT__offset;
    __Vdly__bmp24_stream_to_rgb565__DOT__offset = 0;
    CData/*1:0*/ __Vdly__bmp24_stream_to_rgb565__DOT__phase;
    __Vdly__bmp24_stream_to_rgb565__DOT__phase = 0;
    SData/*9:0*/ __Vdly__bmp24_stream_to_rgb565__DOT__x;
    __Vdly__bmp24_stream_to_rgb565__DOT__x = 0;
    SData/*9:0*/ __Vdly__bmp24_stream_to_rgb565__DOT__y;
    __Vdly__bmp24_stream_to_rgb565__DOT__y = 0;
    IData/*18:0*/ __Vdly__bmp24_stream_to_rgb565__DOT__row_base;
    __Vdly__bmp24_stream_to_rgb565__DOT__row_base = 0;
    CData/*7:0*/ __Vdly__bmp24_stream_to_rgb565__DOT__blue;
    __Vdly__bmp24_stream_to_rgb565__DOT__blue = 0;
    CData/*7:0*/ __Vdly__bmp24_stream_to_rgb565__DOT__green;
    __Vdly__bmp24_stream_to_rgb565__DOT__green = 0;
    // Body
    __Vdly__active = vlSelfRef.active;
    __Vdly__format_error = vlSelfRef.format_error;
    __Vdly__bmp24_stream_to_rgb565__DOT__pos = vlSelfRef.bmp24_stream_to_rgb565__DOT__pos;
    __Vdly__bmp24_stream_to_rgb565__DOT__offset = vlSelfRef.bmp24_stream_to_rgb565__DOT__offset;
    __Vdly__bmp24_stream_to_rgb565__DOT__phase = vlSelfRef.bmp24_stream_to_rgb565__DOT__phase;
    __Vdly__bmp24_stream_to_rgb565__DOT__x = vlSelfRef.bmp24_stream_to_rgb565__DOT__x;
    __Vdly__bmp24_stream_to_rgb565__DOT__y = vlSelfRef.bmp24_stream_to_rgb565__DOT__y;
    __Vdly__bmp24_stream_to_rgb565__DOT__row_base = vlSelfRef.bmp24_stream_to_rgb565__DOT__row_base;
    __Vdly__bmp24_stream_to_rgb565__DOT__blue = vlSelfRef.bmp24_stream_to_rgb565__DOT__blue;
    __Vdly__bmp24_stream_to_rgb565__DOT__green = vlSelfRef.bmp24_stream_to_rgb565__DOT__green;
    if (vlSelfRef.reset) {
        __Vdly__active = 0U;
        vlSelfRef.frame_done = 0U;
        __Vdly__format_error = 0U;
        vlSelfRef.pixel_valid = 0U;
        __Vdly__bmp24_stream_to_rgb565__DOT__pos = 0U;
        __Vdly__bmp24_stream_to_rgb565__DOT__offset = 0U;
        __Vdly__bmp24_stream_to_rgb565__DOT__phase = 0U;
        __Vdly__bmp24_stream_to_rgb565__DOT__x = 0U;
        __Vdly__bmp24_stream_to_rgb565__DOT__y = 0U;
        __Vdly__bmp24_stream_to_rgb565__DOT__row_base = 0x0004ad80U;
        vlSelfRef.pixel_addr = 0U;
        vlSelfRef.pixel_rgb565 = 0U;
        __Vdly__bmp24_stream_to_rgb565__DOT__blue = 0U;
        __Vdly__bmp24_stream_to_rgb565__DOT__green = 0U;
    } else {
        vlSelfRef.frame_done = 0U;
        vlSelfRef.pixel_valid = 0U;
        if (vlSelfRef.start) {
            __Vdly__active = 1U;
            __Vdly__format_error = 0U;
            __Vdly__bmp24_stream_to_rgb565__DOT__pos = 0U;
            __Vdly__bmp24_stream_to_rgb565__DOT__offset = 0U;
            __Vdly__bmp24_stream_to_rgb565__DOT__phase = 0U;
            __Vdly__bmp24_stream_to_rgb565__DOT__x = 0U;
            __Vdly__bmp24_stream_to_rgb565__DOT__y = 0U;
            __Vdly__bmp24_stream_to_rgb565__DOT__row_base = 0x0004ad80U;
        } else if (((IData)(vlSelfRef.active) & (IData)(vlSelfRef.byte_valid))) {
            __Vdly__bmp24_stream_to_rgb565__DOT__pos 
                = ((IData)(1U) + vlSelfRef.bmp24_stream_to_rgb565__DOT__pos);
            if (((((((((0U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos) 
                       | (1U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) 
                      | (0x0000000aU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) 
                     | (0x0000000bU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) 
                    | (0x0000000cU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) 
                   | (0x0000000dU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) 
                  | (0x0000000eU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) 
                 | (((0x0000000fU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos) 
                     || (0x00000010U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) 
                    || (0x00000011U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)))) {
                if ((0U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                    if ((0x42U != (IData)(vlSelfRef.byte_in))) {
                        __Vdly__format_error = 1U;
                    }
                } else if ((1U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                    if ((0x4dU != (IData)(vlSelfRef.byte_in))) {
                        __Vdly__format_error = 1U;
                    }
                } else if ((0x0000000aU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                    __Vdly__bmp24_stream_to_rgb565__DOT__offset 
                        = ((0xffffff00U & __Vdly__bmp24_stream_to_rgb565__DOT__offset) 
                           | (IData)(vlSelfRef.byte_in));
                } else if ((0x0000000bU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                    __Vdly__bmp24_stream_to_rgb565__DOT__offset 
                        = ((0xffff00ffU & __Vdly__bmp24_stream_to_rgb565__DOT__offset) 
                           | ((IData)(vlSelfRef.byte_in) 
                              << 8U));
                } else if ((0x0000000cU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                    __Vdly__bmp24_stream_to_rgb565__DOT__offset 
                        = ((0xff00ffffU & __Vdly__bmp24_stream_to_rgb565__DOT__offset) 
                           | ((IData)(vlSelfRef.byte_in) 
                              << 0x00000010U));
                } else if ((0x0000000dU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                    __Vdly__bmp24_stream_to_rgb565__DOT__offset 
                        = ((0x00ffffffU & __Vdly__bmp24_stream_to_rgb565__DOT__offset) 
                           | ((IData)(vlSelfRef.byte_in) 
                              << 0x00000018U));
                } else if ((0x0000000eU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                    if ((0x28U != (IData)(vlSelfRef.byte_in))) {
                        __Vdly__format_error = 1U;
                    }
                } else if ((0U != (IData)(vlSelfRef.byte_in))) {
                    __Vdly__format_error = 1U;
                }
            } else if (((((((((0x00000012U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos) 
                              | (0x00000013U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) 
                             | ((0x00000014U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos) 
                                || (0x00000015U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos))) 
                            | (0x00000016U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) 
                           | (0x00000017U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) 
                          | ((0x00000018U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos) 
                             || (0x00000019U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos))) 
                         | (0x0000001aU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) 
                        | (0x0000001bU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos))) {
                if ((0x00000012U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                    if ((0x80U != (IData)(vlSelfRef.byte_in))) {
                        __Vdly__format_error = 1U;
                    }
                } else if ((0x00000013U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                    if ((2U != (IData)(vlSelfRef.byte_in))) {
                        __Vdly__format_error = 1U;
                    }
                } else if (((0x00000014U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos) 
                            || (0x00000015U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos))) {
                    if ((0U != (IData)(vlSelfRef.byte_in))) {
                        __Vdly__format_error = 1U;
                    }
                } else if ((0x00000016U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                    if ((0xe0U != (IData)(vlSelfRef.byte_in))) {
                        __Vdly__format_error = 1U;
                    }
                } else if ((0x00000017U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                    if ((1U != (IData)(vlSelfRef.byte_in))) {
                        __Vdly__format_error = 1U;
                    }
                } else if (((0x00000018U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos) 
                            || (0x00000019U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos))) {
                    if ((0U != (IData)(vlSelfRef.byte_in))) {
                        __Vdly__format_error = 1U;
                    }
                } else if ((0x0000001aU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                    if ((1U != (IData)(vlSelfRef.byte_in))) {
                        __Vdly__format_error = 1U;
                    }
                } else if ((0U != (IData)(vlSelfRef.byte_in))) {
                    __Vdly__format_error = 1U;
                }
            } else if ((0x0000001cU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                if ((0x18U != (IData)(vlSelfRef.byte_in))) {
                    __Vdly__format_error = 1U;
                }
            } else if ((((((0x0000001dU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos) 
                           || (0x0000001eU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) 
                          || (0x0000001fU == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) 
                         || (0x00000020U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) 
                        || (0x00000021U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos))) {
                if ((0U != (IData)(vlSelfRef.byte_in))) {
                    __Vdly__format_error = 1U;
                }
            } else if ((0x00000035U == vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                if ((0x00000036U != vlSelfRef.bmp24_stream_to_rgb565__DOT__offset)) {
                    __Vdly__format_error = 1U;
                }
            }
            if (vlSelfRef.format_error) {
                __Vdly__active = 0U;
            } else if ((0x00000036U <= vlSelfRef.bmp24_stream_to_rgb565__DOT__pos)) {
                if ((0U == (IData)(vlSelfRef.bmp24_stream_to_rgb565__DOT__phase))) {
                    __Vdly__bmp24_stream_to_rgb565__DOT__blue 
                        = vlSelfRef.byte_in;
                    __Vdly__bmp24_stream_to_rgb565__DOT__phase = 1U;
                } else if ((1U == (IData)(vlSelfRef.bmp24_stream_to_rgb565__DOT__phase))) {
                    __Vdly__bmp24_stream_to_rgb565__DOT__green 
                        = vlSelfRef.byte_in;
                    __Vdly__bmp24_stream_to_rgb565__DOT__phase = 2U;
                } else if ((2U == (IData)(vlSelfRef.bmp24_stream_to_rgb565__DOT__phase))) {
                    vlSelfRef.pixel_rgb565 = ((0x0000f800U 
                                               & ((IData)(vlSelfRef.byte_in) 
                                                  << 8U)) 
                                              | ((0x000007e0U 
                                                  & ((IData)(vlSelfRef.bmp24_stream_to_rgb565__DOT__green) 
                                                     << 3U)) 
                                                 | (0x0000001fU 
                                                    & ((IData)(vlSelfRef.bmp24_stream_to_rgb565__DOT__blue) 
                                                       >> 3U))));
                    vlSelfRef.pixel_addr = (0x0007ffffU 
                                            & (vlSelfRef.bmp24_stream_to_rgb565__DOT__row_base 
                                               + (IData)(vlSelfRef.bmp24_stream_to_rgb565__DOT__x)));
                    vlSelfRef.pixel_valid = 1U;
                    __Vdly__bmp24_stream_to_rgb565__DOT__phase = 0U;
                    if ((0x027fU == (IData)(vlSelfRef.bmp24_stream_to_rgb565__DOT__x))) {
                        __Vdly__bmp24_stream_to_rgb565__DOT__y 
                            = (0x000003ffU & ((IData)(1U) 
                                              + (IData)(vlSelfRef.bmp24_stream_to_rgb565__DOT__y)));
                        __Vdly__bmp24_stream_to_rgb565__DOT__row_base 
                            = (0x0007ffffU & (vlSelfRef.bmp24_stream_to_rgb565__DOT__row_base 
                                              - (IData)(0x00000280U)));
                        __Vdly__bmp24_stream_to_rgb565__DOT__x = 0U;
                        if ((0x01dfU == (IData)(vlSelfRef.bmp24_stream_to_rgb565__DOT__y))) {
                            __Vdly__active = 0U;
                            vlSelfRef.frame_done = 1U;
                        }
                    } else {
                        __Vdly__bmp24_stream_to_rgb565__DOT__x 
                            = (0x000003ffU & ((IData)(1U) 
                                              + (IData)(vlSelfRef.bmp24_stream_to_rgb565__DOT__x)));
                    }
                }
            }
        }
    }
    vlSelfRef.active = __Vdly__active;
    vlSelfRef.format_error = __Vdly__format_error;
    vlSelfRef.bmp24_stream_to_rgb565__DOT__pos = __Vdly__bmp24_stream_to_rgb565__DOT__pos;
    vlSelfRef.bmp24_stream_to_rgb565__DOT__offset = __Vdly__bmp24_stream_to_rgb565__DOT__offset;
    vlSelfRef.bmp24_stream_to_rgb565__DOT__phase = __Vdly__bmp24_stream_to_rgb565__DOT__phase;
    vlSelfRef.bmp24_stream_to_rgb565__DOT__x = __Vdly__bmp24_stream_to_rgb565__DOT__x;
    vlSelfRef.bmp24_stream_to_rgb565__DOT__y = __Vdly__bmp24_stream_to_rgb565__DOT__y;
    vlSelfRef.bmp24_stream_to_rgb565__DOT__row_base 
        = __Vdly__bmp24_stream_to_rgb565__DOT__row_base;
    vlSelfRef.bmp24_stream_to_rgb565__DOT__blue = __Vdly__bmp24_stream_to_rgb565__DOT__blue;
    vlSelfRef.bmp24_stream_to_rgb565__DOT__green = __Vdly__bmp24_stream_to_rgb565__DOT__green;
}

void Vbmp24_stream_to_rgb565___024root___eval_nba(Vbmp24_stream_to_rgb565___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___eval_nba\n"); );
    Vbmp24_stream_to_rgb565__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vbmp24_stream_to_rgb565___024root___nba_sequent__TOP__0(vlSelf);
    }
}

void Vbmp24_stream_to_rgb565___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___trigger_orInto__act_vec_vec\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((0U >= n));
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vbmp24_stream_to_rgb565___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vbmp24_stream_to_rgb565___024root___eval_phase__act(Vbmp24_stream_to_rgb565___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___eval_phase__act\n"); );
    Vbmp24_stream_to_rgb565__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vbmp24_stream_to_rgb565___024root___eval_triggers_vec__act(vlSelf);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vbmp24_stream_to_rgb565___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vbmp24_stream_to_rgb565___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    return (0U);
}

void Vbmp24_stream_to_rgb565___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vbmp24_stream_to_rgb565___024root___eval_phase__nba(Vbmp24_stream_to_rgb565___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___eval_phase__nba\n"); );
    Vbmp24_stream_to_rgb565__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vbmp24_stream_to_rgb565___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vbmp24_stream_to_rgb565___024root___eval_nba(vlSelf);
        Vbmp24_stream_to_rgb565___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vbmp24_stream_to_rgb565___024root___eval(Vbmp24_stream_to_rgb565___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___eval\n"); );
    Vbmp24_stream_to_rgb565__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00002710U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vbmp24_stream_to_rgb565___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("rtl/sd_bmp\\bmp24_stream_to_rgb565.v", 2, "", "DIDNOTCONVERGE: NBA region did not converge after '--converge-limit' of 10000 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00002710U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vbmp24_stream_to_rgb565___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                VL_FATAL_MT("rtl/sd_bmp\\bmp24_stream_to_rgb565.v", 2, "", "DIDNOTCONVERGE: Active region did not converge after '--converge-limit' of 10000 tries");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactPhaseResult = Vbmp24_stream_to_rgb565___024root___eval_phase__act(vlSelf);
        } while (vlSelfRef.__VactPhaseResult);
        vlSelfRef.__VnbaPhaseResult = Vbmp24_stream_to_rgb565___024root___eval_phase__nba(vlSelf);
    } while (vlSelfRef.__VnbaPhaseResult);
}

#ifdef VL_DEBUG
void Vbmp24_stream_to_rgb565___024root___eval_debug_assertions(Vbmp24_stream_to_rgb565___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vbmp24_stream_to_rgb565___024root___eval_debug_assertions\n"); );
    Vbmp24_stream_to_rgb565__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY(((vlSelfRef.clk & 0xfeU)))) {
        Verilated::overWidthError("clk");
    }
    if (VL_UNLIKELY(((vlSelfRef.reset & 0xfeU)))) {
        Verilated::overWidthError("reset");
    }
    if (VL_UNLIKELY(((vlSelfRef.start & 0xfeU)))) {
        Verilated::overWidthError("start");
    }
    if (VL_UNLIKELY(((vlSelfRef.byte_valid & 0xfeU)))) {
        Verilated::overWidthError("byte_valid");
    }
}
#endif  // VL_DEBUG
