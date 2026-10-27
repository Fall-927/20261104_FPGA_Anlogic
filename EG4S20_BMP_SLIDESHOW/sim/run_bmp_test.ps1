param(
 [string]$VerilatorRoot,
 [string]$VsDevCmd = 'D:\Visual Studio\18\Community\Common7\Tools\VsDevCmd.bat'
)
$ErrorActionPreference='Stop'
if(-not $VerilatorRoot){throw 'Pass -VerilatorRoot pointing to the installed Verilator package'}
$repoRoot=Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot
try {
 $env:VERILATOR_ROOT=$VerilatorRoot
 & "$VerilatorRoot\bin\verilator_bin.exe" --cc --top-module bmp24_stream_to_rgb565 --Mdir sim/obj_bmp -Wno-fatal rtl/sd_bmp/bmp24_stream_to_rgb565.v
 if($LASTEXITCODE -ne 0){throw 'Verilator failed'}
 $build='call "'+$VsDevCmd+'" -arch=x64 >nul && cl /nologo /EHsc /std:c++20 /O2 /I"'+$VerilatorRoot+'\include" /I"'+$VerilatorRoot+'\include\vltstd" /Isim\obj_bmp sim\test_bmp.cpp sim\obj_bmp\*.cpp "'+$VerilatorRoot+'\include\verilated.cpp" "'+$VerilatorRoot+'\include\verilated_threads.cpp" /Fe:sim\test_bmp.exe /Fo:sim\obj_bmp\'
 cmd /c $build
 if($LASTEXITCODE -ne 0){throw 'C++ compilation failed'}
 & .\sim\test_bmp.exe
 if($LASTEXITCODE -ne 0){throw 'BMP test failed'}
} finally {Pop-Location}
