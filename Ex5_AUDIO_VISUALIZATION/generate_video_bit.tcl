# Refuse accidental generation with the unconfigured placeholder.
set source_file [open rtl/hdmi_video_top.v r]
set source_text [read $source_file]
close $source_file
if {[regexp {VIDEO0_LBA\s*=\s*1\s*,} $source_text]} {
 error "VIDEO0_LBA is still the placeholder. Locate the SD file and rebuild first."
}
if {[file mtime rtl/hdmi_video_top.v] > [file mtime HDMI_VIDEO_pr.db]} {
 error "Top-level source is newer than routed database; run build_video.tcl first."
}
open_project HDMI_VIDEO.al
import_db HDMI_VIDEO_pr.db
bitgen -bit HDMI_VIDEO.bit
