# Run only after reviewing the current routed timing report.
# Does not connect to or program hardware.
open_project HDMI_SLIDESHOW.al
import_db HDMI_SLIDESHOW_pr.db
bitgen -bit HDMI_SLIDESHOW.bit
