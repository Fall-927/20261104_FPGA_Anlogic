set f [open rtl/hdmi_media_top.v r]
set text [read $f]
close $f
if {![regexp {parameter MEDIA_LBA_VERIFIED=1,} $text]} {
 error "SD card addresses unverified. Locate all four files, update hdmi_media_top.v, set MEDIA_LBA_VERIFIED=1 and rebuild."
}
foreach f [concat [glob rtl/*.v] [glob rtl/sd_bmp/*.v] [glob rtl/sdram/*.v] [glob al_ip/*.v] [glob constraints/*] [list HDMI_MEDIA.al build_media.tcl]] {
 if {[file mtime $f] > [file mtime HDMI_MEDIA_pr.db]} {error "Sources changed after route: rebuild HDMI_MEDIA first."}
}
open_project HDMI_MEDIA.al
import_db HDMI_MEDIA_pr.db
bitgen -bit HDMI_MEDIA.bit
