# Run in this project's directory using td_commands_prompt.exe.
# No programming or flash writes are performed.
open_project HDMI_720P.al
# open_project imports EG4S20BG256 as the TD 4.6 package token BG256.
elaborate -top hdmi_color_top
read_adc constraints/hdmi_720p.adc
optimize_rtl
read_sdc constraints/hdmi_720p.sdc
optimize_gate -maparea HDMI_720P_gate.area
export_db HDMI_720P_gate.db
place
route
report_area -io_info -file HDMI_720P_phy.area
export_db HDMI_720P_pr.db
start_timer
report_timing -mode FINAL -net_info -file HDMI_720P_timing.rpt
report_clock_summary -file HDMI_720P_clocks.rpt
# Bitstream intentionally gated by manual timing/report inspection.
