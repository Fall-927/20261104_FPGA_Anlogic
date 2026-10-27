open_project HDMI_SLIDESHOW.al
elaborate -top hdmi_slideshow_top
read_adc constraints/hdmi_slideshow.adc
optimize_rtl
read_sdc constraints/hdmi_slideshow.sdc
optimize_gate -maparea HDMI_SLIDESHOW_gate.area
export_db HDMI_SLIDESHOW_gate.db
place
route
report_area -io_info -file HDMI_SLIDESHOW_phy.area
export_db HDMI_SLIDESHOW_pr.db
start_timer
report_timing -mode FINAL -net_info -file HDMI_SLIDESHOW_timing.rpt
report_clock_summary -file HDMI_SLIDESHOW_clocks.rpt
# Review timing and all warnings before bitgen / board download.
