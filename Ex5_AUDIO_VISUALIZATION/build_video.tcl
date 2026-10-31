open_project HDMI_VIDEO.al
elaborate -top hdmi_video_top
read_adc constraints/hdmi_slideshow.adc
optimize_rtl
read_sdc constraints/hdmi_slideshow.sdc
optimize_gate -maparea HDMI_VIDEO_gate.area
export_db HDMI_VIDEO_gate.db
place
route
report_area -io_info -file HDMI_VIDEO_phy.area
export_db HDMI_VIDEO_pr.db
start_timer
report_timing -mode FINAL -net_info -file HDMI_VIDEO_timing.rpt
report_clock_summary -file HDMI_VIDEO_clocks.rpt
# Review constraints and timing before bitgen. No programming performed.
