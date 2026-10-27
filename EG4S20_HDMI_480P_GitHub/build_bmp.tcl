open_project HDMI_BMP.al
elaborate -top hdmi_bmp_top
read_adc constraints/hdmi_bmp.adc
optimize_rtl
read_sdc constraints/hdmi_bmp.sdc
optimize_gate -maparea HDMI_BMP_gate.area
export_db HDMI_BMP_gate.db
place
route
report_area -io_info -file HDMI_BMP_phy.area
export_db HDMI_BMP_pr.db
start_timer
report_timing -mode FINAL -net_info -file HDMI_BMP_timing.rpt
report_clock_summary -file HDMI_BMP_clocks.rpt
# Review timing and all warnings before bitgen / board download.
