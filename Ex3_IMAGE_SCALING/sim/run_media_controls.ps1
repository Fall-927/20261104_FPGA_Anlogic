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
 & "$env:VERILATOR_ROOT\bin\verilator_bin.exe" --cc --top-module media_controls --Mdir sim/obj_media_controls -Wno-fatal -GSCAN_CYCLES=4 -GDEBOUNCE_SCANS=2 -GAUTO_FRAMES=3 -GPHOTO_COUNT=6 rtl/media_controls.v
 if($LASTEXITCODE -ne 0){throw 'Verilator failed'}
 $build='call "'+$VsDevCmd+'" -arch=x64 >nul && cl /nologo /EHsc /std:c++20 /O2 /I"'+$env:VERILATOR_ROOT+'\include" /I"'+$env:VERILATOR_ROOT+'\include\vltstd" /Isim\obj_media_controls sim/test_media_controls.cpp sim\obj_media_controls\*.cpp "'+$env:VERILATOR_ROOT+'\include\verilated.cpp" "'+$env:VERILATOR_ROOT+'\include\verilated_threads.cpp" /Fe:sim\test_media_controls.exe /Fo:sim\obj_media_controls\'
 cmd /c $build
 if($LASTEXITCODE -ne 0){throw 'C++ failed'}
 & .\sim\test_media_controls.exe
 if($LASTEXITCODE -ne 0){throw 'Controls failed'}
} finally {Pop-Location}
