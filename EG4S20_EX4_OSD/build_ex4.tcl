# Resolve relative RTL and constraint paths from this script, including GUI use.
cd [file dirname [file normalize [info script]]]
open_project HDMI_EX4_OSD.al
elaborate -top hdmi_slideshow_top
read_adc constraints/hdmi_slideshow.adc
optimize_rtl
read_sdc constraints/hdmi_slideshow.sdc
optimize_gate -maparea HDMI_EX4_OSD_gate.area
export_db HDMI_EX4_OSD_gate.db
place
route
report_area -io_info -file HDMI_EX4_OSD_phy.area
export_db HDMI_EX4_OSD_pr.db
start_timer
report_timing -mode FINAL -net_info -file HDMI_EX4_OSD_timing.rpt
report_clock_summary -file HDMI_EX4_OSD_clocks.rpt
# Review timing and all warnings before bitgen / board download.
