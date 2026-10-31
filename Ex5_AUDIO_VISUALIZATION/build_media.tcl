open_project HDMI_MEDIA.al
elaborate -top hdmi_media_top
read_adc constraints/hdmi_slideshow.adc
optimize_rtl
read_sdc constraints/hdmi_media.sdc
optimize_gate
place
route
export_db HDMI_MEDIA_pr.db
report_area -io_info -file HDMI_MEDIA_phy.area
start_timer
report_timing -mode FINAL -net_info -file HDMI_MEDIA_timing.rpt
