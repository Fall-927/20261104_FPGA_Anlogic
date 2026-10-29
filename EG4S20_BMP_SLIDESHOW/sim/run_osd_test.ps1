param(
 [string]$Iverilog='iverilog',
 [string]$Vvp='vvp',
 [string]$OutputDirectory=(Join-Path $env:TEMP 'eg4s20-osd-test'),
 [switch]$Preview
)
$ErrorActionPreference='Stop'
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$OutputDirectory=(Resolve-Path -LiteralPath $OutputDirectory).Path
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
 $simulation=Join-Path $OutputDirectory 'osd.vvp'
 & $Iverilog -g2005 -Wall -s osd_tb -o $simulation rtl/slideshow_osd.v sim/osd_tb.v
 if($LASTEXITCODE -ne 0){throw 'OSD compilation failed'}
 if($Preview){ & $Vvp $simulation ('+preview='+(Join-Path $OutputDirectory 'osd_preview.ppm')) }
 else { & $Vvp $simulation }
 if($LASTEXITCODE -ne 0){throw 'OSD simulation failed'}
 $integration=Join-Path $OutputDirectory 'osd_hdmi.vvp'
 & $Iverilog -g2005 -Wall -s osd_hdmi_tb -o $integration rtl/slideshow_osd.v rtl/hdmi_audio_tx.v rtl/tmds_encoder.v sim/osd_hdmi_tb.v
 if($LASTEXITCODE -ne 0){throw 'OSD/HDMI integration compilation failed'}
 & $Vvp $integration
 if($LASTEXITCODE -ne 0){throw 'OSD/HDMI integration simulation failed'}
} finally {Pop-Location}
