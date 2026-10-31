# Run only after reviewing the current routed timing report.
# Does not connect to or program hardware.
cd [file dirname [file normalize [info script]]]
open_project HDMI_EX4_OSD.al
import_db HDMI_EX4_OSD_pr.db
bitgen -bit HDMI_EX4_OSD.bit
