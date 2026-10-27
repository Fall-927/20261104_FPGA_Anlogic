// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vsd_bmp_fixed_lba_reader.h for the primary calling header

#include "Vsd_bmp_fixed_lba_reader__pch.h"

void Vsd_bmp_fixed_lba_reader___024root___eval_triggers_vec__act(Vsd_bmp_fixed_lba_reader___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___eval_triggers_vec__act\n"); );
    Vsd_bmp_fixed_lba_reader__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
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

bool Vsd_bmp_fixed_lba_reader___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___trigger_anySet__act\n"); );
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

void Vsd_bmp_fixed_lba_reader___024root___nba_sequent__TOP__0(Vsd_bmp_fixed_lba_reader___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___nba_sequent__TOP__0\n"); );
    Vsd_bmp_fixed_lba_reader__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*7:0*/ __Vtask_sd_bmp_fixed_lba_reader__DOT__transfer__5__value;
    __Vtask_sd_bmp_fixed_lba_reader__DOT__transfer__5__value = 0;
    QData/*47:0*/ __Vtask_sd_bmp_fixed_lba_reader__DOT__issue__14__value;
    __Vtask_sd_bmp_fixed_lba_reader__DOT__issue__14__value = 0;
    QData/*47:0*/ __Vtask_sd_bmp_fixed_lba_reader__DOT__issue__22__value;
    __Vtask_sd_bmp_fixed_lba_reader__DOT__issue__22__value = 0;
    IData/*31:0*/ __Vdly__sector;
    __Vdly__sector = 0;
    CData/*4:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__state;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0;
    CData/*4:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 0;
    QData/*47:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__command;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__command = 0;
    CData/*2:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__cmd_byte;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__cmd_byte = 0;
    CData/*2:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__extra;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__extra = 0;
    CData/*7:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__response;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__response = 0;
    SData/*15:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__tries;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__tries = 0;
    IData/*19:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout = 0;
    SData/*9:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__count;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__count = 0;
    IData/*31:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__blocks;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__blocks = 0;
    IData/*31:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__power_wait;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__power_wait = 0;
    IData/*31:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__tail;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__tail = 0;
    CData/*2:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__op;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__op = 0;
    CData/*0:0*/ __Vdly__sd_sck;
    __Vdly__sd_sck = 0;
    CData/*7:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__rx;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__rx = 0;
    CData/*0:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__byte_busy;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__byte_busy = 0;
    CData/*0:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__byte_done;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__byte_done = 0;
    CData/*7:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__shift;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__shift = 0;
    CData/*6:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__divider;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__divider = 0;
    CData/*2:0*/ __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__bitnum;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__bitnum = 0;
    // Body
    __Vdly__sector = vlSelfRef.sector;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte 
        = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__after_byte;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__command = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__command;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__cmd_byte 
        = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__cmd_byte;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__extra = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__extra;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__response 
        = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__response;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__tries = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tries;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__timeout;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__count = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__count;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__blocks = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__blocks;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__power_wait 
        = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__power_wait;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__tail = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tail;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__op = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__op;
    __Vdly__sd_sck = vlSelfRef.sd_sck;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__rx = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__rx;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__byte_busy 
        = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__byte_busy;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__byte_done 
        = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__byte_done;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__shift 
        = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__spi__DOT__shift;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__divider 
        = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__spi__DOT__divider;
    __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__bitnum 
        = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__spi__DOT__bitnum;
    if (vlSelfRef.reset) {
        __Vdly__sd_sck = 0U;
        vlSelfRef.sd_mosi = 1U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__rx = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__byte_busy = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__byte_done = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__shift = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__divider = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__bitnum = 0U;
        vlSelfRef.sd_cs = 1U;
        __Vdly__sector = 0x00000800U;
        vlSelfRef.data_byte = 0U;
        vlSelfRef.data_valid = 0U;
        vlSelfRef.busy = 1U;
        vlSelfRef.done = 0U;
        vlSelfRef.error = 0U;
        vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 0U;
        vlSelfRef.sd_bmp_fixed_lba_reader__DOT__slow = 1U;
        vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__command = 0ULL;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__cmd_byte = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__extra = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__response = 0xffU;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__tries = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__count = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__blocks = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__power_wait = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__tail = 0U;
        __Vdly__sd_bmp_fixed_lba_reader__DOT__op = 0U;
    } else {
        __Vdly__sd_bmp_fixed_lba_reader__DOT__byte_done = 0U;
        if (vlSelfRef.sd_bmp_fixed_lba_reader__DOT__byte_busy) {
            if (((IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__spi__DOT__divider) 
                 == ((IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__slow)
                      ? 0x3eU : 1U))) {
                __Vdly__sd_sck = (1U & (~ (IData)(vlSelfRef.sd_sck)));
                __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__divider = 0U;
                if (vlSelfRef.sd_sck) {
                    if ((7U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__spi__DOT__bitnum))) {
                        __Vdly__sd_bmp_fixed_lba_reader__DOT__byte_busy = 0U;
                        __Vdly__sd_bmp_fixed_lba_reader__DOT__byte_done = 1U;
                        vlSelfRef.sd_mosi = 1U;
                    } else {
                        __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__bitnum 
                            = (7U & ((IData)(1U) + (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__spi__DOT__bitnum)));
                        __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__shift 
                            = (1U | (0x000000feU & 
                                     ((IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__spi__DOT__shift) 
                                      << 1U)));
                        vlSelfRef.sd_mosi = (1U & ((IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__spi__DOT__shift) 
                                                   >> 6U));
                    }
                } else {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__rx 
                        = ((0x000000feU & ((IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__rx) 
                                           << 1U)) 
                           | (IData)(vlSelfRef.sd_miso));
                }
            } else {
                __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__divider 
                    = (0x0000007fU & ((IData)(1U) + (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__spi__DOT__divider)));
            }
        } else {
            __Vdly__sd_sck = 0U;
            if (vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch) {
                __Vdly__sd_bmp_fixed_lba_reader__DOT__byte_busy = 1U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__shift 
                    = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx;
                vlSelfRef.sd_mosi = (1U & ((IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx) 
                                           >> 7U));
                __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__divider = 0U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__bitnum = 0U;
            }
        }
        vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 0U;
        vlSelfRef.data_valid = 0U;
        if (((((((((0U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state)) 
                   | (1U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) 
                  | (2U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) 
                 | (0x0eU == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) 
                | (3U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) 
               | (0x0bU == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) 
              | (4U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) 
             | (5U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state)))) {
            if ((0U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) {
                if ((0x0000c350U == vlSelfRef.sd_bmp_fixed_lba_reader__DOT__power_wait)) {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__count = 0U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 1U;
                } else {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__power_wait 
                        = ((IData)(1U) + vlSelfRef.sd_bmp_fixed_lba_reader__DOT__power_wait);
                }
            } else if ((1U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) {
                if ((0x000aU == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__count))) {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__command = 0x0000400000000095ULL;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__cmd_byte = 0U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__op = 0U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 2U;
                    vlSelfRef.sd_cs = 1U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout = 0U;
                } else {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__count 
                        = (0x000003ffU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__count)));
                    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
                    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 1U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
                }
            } else if ((2U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) {
                vlSelfRef.sd_cs = 1U;
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 0x0eU;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
            } else if ((0x0eU == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) {
                vlSelfRef.sd_cs = 0U;
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 3U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
            } else if ((3U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) {
                if ((6U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__cmd_byte))) {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout = 0U;
                    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
                    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 4U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
                } else {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__cmd_byte 
                        = (7U & ((IData)(1U) + (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__cmd_byte)));
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__command 
                        = (0x00000000000000ffULL | 
                           (0x0000ffffffffff00ULL & 
                            (vlSelfRef.sd_bmp_fixed_lba_reader__DOT__command 
                             << 8U)));
                    __Vtask_sd_bmp_fixed_lba_reader__DOT__transfer__5__value 
                        = (0x000000ffU & (IData)((vlSelfRef.sd_bmp_fixed_lba_reader__DOT__command 
                                                  >> 0x28U)));
                    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx 
                        = __Vtask_sd_bmp_fixed_lba_reader__DOT__transfer__5__value;
                    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 3U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
                }
            } else if ((0x0bU == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) {
                if (vlSelfRef.sd_bmp_fixed_lba_reader__DOT__byte_done) {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state 
                        = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__after_byte;
                }
            } else if ((4U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) {
                if ((0x00000080U & (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__rx))) {
                    if ((0x000000ffU == vlSelfRef.sd_bmp_fixed_lba_reader__DOT__timeout)) {
                        __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0dU;
                    } else {
                        __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout 
                            = (0x000fffffU & ((IData)(1U) 
                                              + vlSelfRef.sd_bmp_fixed_lba_reader__DOT__timeout));
                        vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
                        vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                        __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 4U;
                        __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
                    }
                } else {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__response 
                        = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__rx;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__extra = 0U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__tail = 0U;
                    if (((1U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__op)) 
                         | (4U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__op)))) {
                        vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
                        vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                        __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 5U;
                        __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
                    } else {
                        __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 6U;
                    }
                }
            } else {
                __Vdly__sd_bmp_fixed_lba_reader__DOT__tail 
                    = ((vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tail 
                        << 8U) | (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__rx));
                if ((3U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__extra))) {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 6U;
                } else {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__extra 
                        = (7U & ((IData)(1U) + (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__extra)));
                    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
                    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 5U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
                }
            }
        } else if ((6U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) {
            vlSelfRef.sd_cs = 1U;
            if ((0U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__op))) {
                if ((1U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__response))) {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__command = 0x000048000001aa87ULL;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__cmd_byte = 0U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__op = 1U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 2U;
                    vlSelfRef.sd_cs = 1U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout = 0U;
                } else {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0dU;
                }
            } else if ((1U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__op))) {
                if (((1U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__response)) 
                     & (0x000001aaU == vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tail))) {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__command = 0x0000770000000001ULL;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__cmd_byte = 0U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__op = 2U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 2U;
                    vlSelfRef.sd_cs = 1U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout = 0U;
                } else {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0dU;
                }
            } else if ((2U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__op))) {
                if (((1U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__response)) 
                     | (0U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__response)))) {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__command = 0x0000694000000001ULL;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__cmd_byte = 0U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__op = 3U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 2U;
                    vlSelfRef.sd_cs = 1U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout = 0U;
                } else {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0dU;
                }
            } else if ((3U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__op))) {
                if ((0U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__response))) {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__command = 0x00007a0000000001ULL;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__cmd_byte = 0U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__op = 4U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 2U;
                    vlSelfRef.sd_cs = 1U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout = 0U;
                } else if (((1U != (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__response)) 
                            | (0x07d0U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tries)))) {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0dU;
                } else {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__tries 
                        = (0x0000ffffU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tries)));
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__command = 0x0000770000000001ULL;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__cmd_byte = 0U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__op = 2U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 2U;
                    vlSelfRef.sd_cs = 1U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout = 0U;
                }
            } else if ((4U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__op))) {
                if (((0U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__response)) 
                     & (3U == (vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tail 
                               >> 0x1eU)))) {
                    __Vtask_sd_bmp_fixed_lba_reader__DOT__issue__14__value 
                        = (0x0000510000000001ULL | 
                           ((QData)((IData)(vlSelfRef.sector)) 
                            << 8U));
                    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__slow = 0U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__command 
                        = __Vtask_sd_bmp_fixed_lba_reader__DOT__issue__14__value;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__cmd_byte = 0U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__op = 5U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 2U;
                    vlSelfRef.sd_cs = 1U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout = 0U;
                } else {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0dU;
                }
            } else if ((5U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__op))) {
                if ((0U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__response))) {
                    vlSelfRef.sd_cs = 0U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout = 0U;
                    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
                    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 7U;
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
                } else {
                    __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0dU;
                }
            } else {
                __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0dU;
            }
        } else if ((7U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) {
            if ((0xfeU == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__rx))) {
                __Vdly__sd_bmp_fixed_lba_reader__DOT__count = 0U;
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 8U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
            } else if (((0xffU != (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__rx)) 
                        | (0x000fffffU == vlSelfRef.sd_bmp_fixed_lba_reader__DOT__timeout))) {
                __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0dU;
            } else {
                __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout 
                    = (0x000fffffU & ((IData)(1U) + vlSelfRef.sd_bmp_fixed_lba_reader__DOT__timeout));
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 7U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
            }
        } else if ((8U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) {
            vlSelfRef.data_byte = vlSelfRef.sd_bmp_fixed_lba_reader__DOT__rx;
            vlSelfRef.data_valid = 1U;
            if ((0x01ffU == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__count))) {
                __Vdly__sd_bmp_fixed_lba_reader__DOT__count = 0U;
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 9U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
            } else {
                __Vdly__sd_bmp_fixed_lba_reader__DOT__count 
                    = (0x000003ffU & ((IData)(1U) + (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__count)));
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 8U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
            }
        } else if ((9U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) {
            if ((0U == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__count))) {
                __Vdly__sd_bmp_fixed_lba_reader__DOT__count = 1U;
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 9U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
            } else {
                vlSelfRef.sd_cs = 1U;
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tx = 0xffU;
                vlSelfRef.sd_bmp_fixed_lba_reader__DOT__launch = 1U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte = 0x0aU;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0bU;
            }
        } else if ((0x0aU == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) {
            if ((1U == vlSelfRef.sd_bmp_fixed_lba_reader__DOT__blocks)) {
                __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0cU;
            } else {
                __Vdly__sd_bmp_fixed_lba_reader__DOT__blocks 
                    = ((IData)(1U) + vlSelfRef.sd_bmp_fixed_lba_reader__DOT__blocks);
                __Vdly__sector = ((IData)(1U) + vlSelfRef.sector);
                __Vtask_sd_bmp_fixed_lba_reader__DOT__issue__22__value 
                    = (0x0000510000000001ULL | ((QData)((IData)(
                                                                ((IData)(1U) 
                                                                 + vlSelfRef.sector))) 
                                                << 8U));
                __Vdly__sd_bmp_fixed_lba_reader__DOT__command 
                    = __Vtask_sd_bmp_fixed_lba_reader__DOT__issue__22__value;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__cmd_byte = 0U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__op = 5U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 2U;
                vlSelfRef.sd_cs = 1U;
                __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout = 0U;
            }
        } else if ((0x0cU == (IData)(vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state))) {
            vlSelfRef.busy = 0U;
            vlSelfRef.done = 1U;
            vlSelfRef.sd_cs = 1U;
        } else {
            vlSelfRef.busy = 0U;
            vlSelfRef.error = 1U;
            vlSelfRef.sd_cs = 1U;
            __Vdly__sd_bmp_fixed_lba_reader__DOT__state = 0x0dU;
        }
    }
    vlSelfRef.sd_sck = __Vdly__sd_sck;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__byte_busy 
        = __Vdly__sd_bmp_fixed_lba_reader__DOT__byte_busy;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__spi__DOT__shift 
        = __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__shift;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__spi__DOT__divider 
        = __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__divider;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__spi__DOT__bitnum 
        = __Vdly__sd_bmp_fixed_lba_reader__DOT__spi__DOT__bitnum;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__byte_done 
        = __Vdly__sd_bmp_fixed_lba_reader__DOT__byte_done;
    vlSelfRef.sector = __Vdly__sector;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__state = __Vdly__sd_bmp_fixed_lba_reader__DOT__state;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__after_byte 
        = __Vdly__sd_bmp_fixed_lba_reader__DOT__after_byte;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__command 
        = __Vdly__sd_bmp_fixed_lba_reader__DOT__command;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__cmd_byte 
        = __Vdly__sd_bmp_fixed_lba_reader__DOT__cmd_byte;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__extra = __Vdly__sd_bmp_fixed_lba_reader__DOT__extra;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__response 
        = __Vdly__sd_bmp_fixed_lba_reader__DOT__response;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tries = __Vdly__sd_bmp_fixed_lba_reader__DOT__tries;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__timeout 
        = __Vdly__sd_bmp_fixed_lba_reader__DOT__timeout;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__count = __Vdly__sd_bmp_fixed_lba_reader__DOT__count;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__blocks 
        = __Vdly__sd_bmp_fixed_lba_reader__DOT__blocks;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__power_wait 
        = __Vdly__sd_bmp_fixed_lba_reader__DOT__power_wait;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__tail = __Vdly__sd_bmp_fixed_lba_reader__DOT__tail;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__op = __Vdly__sd_bmp_fixed_lba_reader__DOT__op;
    vlSelfRef.sd_bmp_fixed_lba_reader__DOT__rx = __Vdly__sd_bmp_fixed_lba_reader__DOT__rx;
}

void Vsd_bmp_fixed_lba_reader___024root___eval_nba(Vsd_bmp_fixed_lba_reader___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___eval_nba\n"); );
    Vsd_bmp_fixed_lba_reader__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vsd_bmp_fixed_lba_reader___024root___nba_sequent__TOP__0(vlSelf);
    }
}

void Vsd_bmp_fixed_lba_reader___024root___trigger_orInto__act_vec_vec(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___trigger_orInto__act_vec_vec\n"); );
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
VL_ATTR_COLD void Vsd_bmp_fixed_lba_reader___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

bool Vsd_bmp_fixed_lba_reader___024root___eval_phase__act(Vsd_bmp_fixed_lba_reader___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___eval_phase__act\n"); );
    Vsd_bmp_fixed_lba_reader__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vsd_bmp_fixed_lba_reader___024root___eval_triggers_vec__act(vlSelf);
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vsd_bmp_fixed_lba_reader___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
    Vsd_bmp_fixed_lba_reader___024root___trigger_orInto__act_vec_vec(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    return (0U);
}

void Vsd_bmp_fixed_lba_reader___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vsd_bmp_fixed_lba_reader___024root___eval_phase__nba(Vsd_bmp_fixed_lba_reader___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___eval_phase__nba\n"); );
    Vsd_bmp_fixed_lba_reader__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vsd_bmp_fixed_lba_reader___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vsd_bmp_fixed_lba_reader___024root___eval_nba(vlSelf);
        Vsd_bmp_fixed_lba_reader___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vsd_bmp_fixed_lba_reader___024root___eval(Vsd_bmp_fixed_lba_reader___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___eval\n"); );
    Vsd_bmp_fixed_lba_reader__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00002710U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vsd_bmp_fixed_lba_reader___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("rtl/sd_bmp\\sd_bmp_fixed_lba_reader.v", 2, "", "DIDNOTCONVERGE: NBA region did not converge after '--converge-limit' of 10000 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00002710U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vsd_bmp_fixed_lba_reader___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                VL_FATAL_MT("rtl/sd_bmp\\sd_bmp_fixed_lba_reader.v", 2, "", "DIDNOTCONVERGE: Active region did not converge after '--converge-limit' of 10000 tries");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
            vlSelfRef.__VactPhaseResult = Vsd_bmp_fixed_lba_reader___024root___eval_phase__act(vlSelf);
        } while (vlSelfRef.__VactPhaseResult);
        vlSelfRef.__VnbaPhaseResult = Vsd_bmp_fixed_lba_reader___024root___eval_phase__nba(vlSelf);
    } while (vlSelfRef.__VnbaPhaseResult);
}

#ifdef VL_DEBUG
void Vsd_bmp_fixed_lba_reader___024root___eval_debug_assertions(Vsd_bmp_fixed_lba_reader___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___eval_debug_assertions\n"); );
    Vsd_bmp_fixed_lba_reader__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY(((vlSelfRef.clk & 0xfeU)))) {
        Verilated::overWidthError("clk");
    }
    if (VL_UNLIKELY(((vlSelfRef.reset & 0xfeU)))) {
        Verilated::overWidthError("reset");
    }
    if (VL_UNLIKELY(((vlSelfRef.sd_miso & 0xfeU)))) {
        Verilated::overWidthError("sd_miso");
    }
}
#endif  // VL_DEBUG
