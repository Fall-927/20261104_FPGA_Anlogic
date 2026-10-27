# Run in this project's directory. Does not program the board.
set f [open al_ip/PLL.v r]
set pll_source [read $f]
close $f
if {![regexp {module\s+PLL\s*\(} $pll_source]} {
    error "Missing TD-generated PLL module in al_ip/PLL.v"
}
open_project HDMI_480P.al
elaborate -top hdmi_color_top
read_adc constraints/hdmi_480p.adc
optimize_rtl
read_sdc constraints/hdmi_480p.sdc
optimize_gate -maparea HDMI_480P_gate.area
export_db HDMI_480P_gate.db
place
route
report_area -io_info -file HDMI_480P_phy.area
export_db HDMI_480P_pr.db
start_timer
report_timing -mode FINAL -net_info -file HDMI_480P_timing.rpt
report_clock_summary -file HDMI_480P_clocks.rpt
# Inspect timing before running bitgen. Never programs the board automatically.
