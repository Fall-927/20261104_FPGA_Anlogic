param(
 [string]$VerilatorRoot=$env:VERILATOR_ROOT,
 [string]$VsDevCmd=$env:VSDEVCMD
)
$ErrorActionPreference='Stop'
if(!$VerilatorRoot){$VerilatorRoot='C:\Users\yushe\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\Lib\site-packages\verilator'}
if(!$VsDevCmd){$VsDevCmd='D:\Visual Studio\18\Community\Common7\Tools\VsDevCmd.bat'}
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
 $env:VERILATOR_ROOT=$VerilatorRoot
 & "$env:VERILATOR_ROOT\bin\verilator_bin.exe" --cc --top-module audio_wave_overlay --Mdir sim/obj_audio_wave -Wno-fatal rtl/audio_wave_overlay.v
 if($LASTEXITCODE -ne 0){throw 'Verilator failed'}
 $build='call "'+$VsDevCmd+'" -arch=x64 >nul && cl /nologo /EHsc /std:c++20 /O2 /I"'+$env:VERILATOR_ROOT+'\include" /I"'+$env:VERILATOR_ROOT+'\include\vltstd" /Isim\obj_audio_wave sim/test_audio_wave.cpp sim\obj_audio_wave\*.cpp "'+$env:VERILATOR_ROOT+'\include\verilated.cpp" "'+$env:VERILATOR_ROOT+'\include\verilated_threads.cpp" /Fe:sim\test_audio_wave.exe /Fo:sim\obj_audio_wave\'
 cmd /c $build
 if($LASTEXITCODE -ne 0){throw 'C++ failed'}
 & .\sim\test_audio_wave.exe
 if($LASTEXITCODE -ne 0){throw 'Audio waveform failed'}
} finally {Pop-Location}
