param([string]$IcarusBin='D:\FPGAqiansai\_tools\iverilog\mingw64\bin')
$ErrorActionPreference='Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
 $env:PATH=$IcarusBin+';'+$env:PATH
 & "$IcarusBin\iverilog.exe" -g2012 -s transition_tb -o sim/transition_test.vvp rtl/slideshow_controls.v rtl/slideshow_fade.v sim/transition_tb.v
 if($LASTEXITCODE -ne 0){throw 'Transition test compilation failed'}
 & "$IcarusBin\vvp.exe" sim/transition_test.vvp
 if($LASTEXITCODE -ne 0){throw 'Transition simulation failed'}
} finally {Pop-Location}
