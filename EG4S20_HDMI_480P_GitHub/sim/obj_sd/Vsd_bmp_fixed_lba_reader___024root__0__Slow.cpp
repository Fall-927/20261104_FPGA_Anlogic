// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vsd_bmp_fixed_lba_reader.h for the primary calling header

#include "Vsd_bmp_fixed_lba_reader__pch.h"

VL_ATTR_COLD void Vsd_bmp_fixed_lba_reader___024root___eval_static(Vsd_bmp_fixed_lba_reader___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___eval_static\n"); );
    Vsd_bmp_fixed_lba_reader__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vtrigprevexpr___TOP__clk__0 = vlSelfRef.clk;
    vlSelfRef.__Vtrigprevexpr___TOP__reset__0 = vlSelfRef.reset;
}

VL_ATTR_COLD void Vsd_bmp_fixed_lba_reader___024root___eval_initial(Vsd_bmp_fixed_lba_reader___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___eval_initial\n"); );
    Vsd_bmp_fixed_lba_reader__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vsd_bmp_fixed_lba_reader___024root___eval_final(Vsd_bmp_fixed_lba_reader___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___eval_final\n"); );
    Vsd_bmp_fixed_lba_reader__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vsd_bmp_fixed_lba_reader___024root___eval_settle(Vsd_bmp_fixed_lba_reader___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___eval_settle\n"); );
    Vsd_bmp_fixed_lba_reader__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

bool Vsd_bmp_fixed_lba_reader___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vsd_bmp_fixed_lba_reader___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vsd_bmp_fixed_lba_reader___024root___trigger_anySet__act(triggers))))) {
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

VL_ATTR_COLD void Vsd_bmp_fixed_lba_reader___024root___ctor_var_reset(Vsd_bmp_fixed_lba_reader___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsd_bmp_fixed_lba_reader___024root___ctor_var_reset\n"); );
    Vsd_bmp_fixed_lba_reader__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->clk = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16707436170211756652ull);
    vlSelf->reset = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9928399931838511862ull);
    vlSelf->sd_miso = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4698123240943661924ull);
    vlSelf->sd_cs = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16795631114736746752ull);
    vlSelf->sd_sck = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8650226086194560258ull);
    vlSelf->sd_mosi = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11491467035719322176ull);
    vlSelf->sector = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5758738122788432806ull);
    vlSelf->data_byte = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 5882154900231937712ull);
    vlSelf->data_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10948900208641353254ull);
    vlSelf->busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6386567572483775230ull);
    vlSelf->done = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10296494685231209730ull);
    vlSelf->error = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10895628271336369153ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__tx = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 4922935878466271236ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__rx = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 9852717383899143606ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__launch = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8304089939809267814ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__slow = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7652940989300728292ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__byte_busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10763150912950351107ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__byte_done = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1841069573287432396ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__state = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 4845424797572434353ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__after_byte = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 7792656383630409167ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__command = VL_SCOPED_RAND_RESET_Q(48, __VscopeHash, 421170664019272494ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__cmd_byte = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 17513588000870009383ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__extra = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 7326175130364466682ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__op = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 4120970926135556706ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__response = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 16096834414416779379ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__tries = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 12409220882273480187ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__timeout = VL_SCOPED_RAND_RESET_I(20, __VscopeHash, 17948248033938316957ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__count = VL_SCOPED_RAND_RESET_I(10, __VscopeHash, 16140766784010337836ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__blocks = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 12065563417780764996ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__power_wait = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 4465656519893092183ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__tail = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5029396237030972287ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__spi__DOT__shift = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 7948526960729314093ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__spi__DOT__divider = VL_SCOPED_RAND_RESET_I(7, __VscopeHash, 18409347096784231853ull);
    vlSelf->sd_bmp_fixed_lba_reader__DOT__spi__DOT__bitnum = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 7743122525719846956ull);
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__reset__0 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
}
