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
# Inspect timing before running bitgen; never programs hardware.
