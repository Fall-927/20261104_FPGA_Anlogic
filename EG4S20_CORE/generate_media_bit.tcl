cd [file dirname [file normalize [info script]]]
set f [open rtl/hdmi_media_top.v r]
set text [read $f]
close $f
if {![regexp {parameter MEDIA_LBA_VERIFIED=1,} $text]} {
 error "SD card addresses unverified. Locate all eight photos and video, update hdmi_media_top.v, set MEDIA_LBA_VERIFIED=1 and rebuild."
}
if {![file exists BUILD_STARTED.txt]} {error "Missing build start marker; rebuild with current build_media.tcl."}
set f [open BUILD_STARTED.txt r]
set started [string trim [read $f]]
close $f
foreach f [concat [glob rtl/*.v] [glob rtl/*.vh] [glob rtl/sd_bmp/*.v] [glob rtl/sdram/*.v] [glob al_ip/*.v] [glob constraints/*] [list HDMI_MEDIA.al build_media.tcl]] {
 if {[file mtime $f] > $started} {error "Sources changed during/after build: rebuild HDMI_MEDIA first."}
}
set f [open HDMI_MEDIA_timing.rpt r]
set timing [read $f]
close $f
foreach {matched count} [regexp -all -inline {([0-9]+) errors detected} $timing] {
 if {$count != 0} {error "Timing failed: do not generate a programming file."}
}
if {![regexp {errors detected} $timing]} {error "Timing report missing clock checks."}
puts "NOTICE: Firmware addresses are bound to the verified SD card; do not move/replace its media files."
open_project HDMI_MEDIA.al
import_db HDMI_MEDIA_pr.db
bitgen -bit HDMI_MEDIA.bit
