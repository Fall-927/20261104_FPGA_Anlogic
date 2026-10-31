param([string]$IcarusBin='D:\FPGAqiansai\_tools\iverilog\mingw64\bin')
$ErrorActionPreference='Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
 $env:PATH=$IcarusBin+';'+$env:PATH
 & "$IcarusBin\iverilog.exe" -g2012 -s settings_tb -o sim/settings_test.vvp rtl/display_settings.v rtl/display_adjust.v rtl/display_osd.v sim/settings_tb.v
 if($LASTEXITCODE -ne 0){throw 'Compilation failed'}
 & "$IcarusBin\vvp.exe" sim/settings_test.vvp
 if($LASTEXITCODE -ne 0){throw 'Settings simulation failed'}
 & "$IcarusBin\iverilog.exe" -g2012 -s settings_keys_tb -o sim/settings_keys.vvp rtl/slideshow_controls.v rtl/display_settings.v sim/settings_keys_tb.v
 if($LASTEXITCODE -ne 0){throw 'Key test compilation failed'}
 & "$IcarusBin\vvp.exe" sim/settings_keys.vvp
 if($LASTEXITCODE -ne 0){throw 'Key simulation failed'}
 & "$IcarusBin\iverilog.exe" -g2012 -s direct_switch_tb -o sim/direct_switch.vvp rtl/slideshow_controls.v sim/direct_switch_tb.v
 if($LASTEXITCODE -ne 0){throw 'Direct switch compilation failed'}
 & "$IcarusBin\vvp.exe" sim/direct_switch.vvp
 if($LASTEXITCODE -ne 0){throw 'Direct switch simulation failed'}
}finally{Pop-Location}
