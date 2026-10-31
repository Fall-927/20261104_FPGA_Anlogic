param(
 [Parameter(Mandatory=$true)][string]$VerilatorRoot,
 [string]$VsDevCmd='D:\Visual Studio\18\Community\Common7\Tools\VsDevCmd.bat'
)
$ErrorActionPreference='Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
 $env:VERILATOR_ROOT=$VerilatorRoot
 & "$VerilatorRoot\bin\verilator_bin.exe" --cc --top-module slideshow_controls -GSCAN_CYCLES=8 -GDEBOUNCE_SCANS=2 -GAUTO_FRAMES=3 --Mdir sim/obj_controls -Wno-fatal rtl/slideshow_controls.v
 if($LASTEXITCODE -ne 0){throw 'Verilator failed'}
 $build='call "'+$VsDevCmd+'" -arch=x64 >nul && cl /nologo /EHsc /std:c++20 /O2 /I"'+$VerilatorRoot+'\include" /I"'+$VerilatorRoot+'\include\vltstd" /Isim\obj_controls sim\test_controls.cpp sim\obj_controls\*.cpp "'+$VerilatorRoot+'\include\verilated.cpp" "'+$VerilatorRoot+'\include\verilated_threads.cpp" /Fe:sim\test_controls.exe /Fo:sim\obj_controls\'
 cmd /c $build
 if($LASTEXITCODE -ne 0){throw 'C++ compilation failed'}
 & .\sim\test_controls.exe
 if($LASTEXITCODE -ne 0){throw 'Controls test failed'}
}finally{Pop-Location}
