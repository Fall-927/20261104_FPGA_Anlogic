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
 & "$env:VERILATOR_ROOT\bin\verilator_bin.exe" --cc --top-module bmp_scale_stream --Mdir sim/obj_bmp_scale -Wno-fatal rtl/bmp_scale_stream.v rtl/scale_divider.v
 if($LASTEXITCODE -ne 0){throw 'Verilator failed'}
 $build='call "'+$VsDevCmd+'" -arch=x64 >nul && cl /nologo /EHsc /std:c++20 /O2 /I"'+$env:VERILATOR_ROOT+'\include" /I"'+$env:VERILATOR_ROOT+'\include\vltstd" /Isim\obj_bmp_scale sim/test_bmp_scale.cpp sim\obj_bmp_scale\*.cpp "'+$env:VERILATOR_ROOT+'\include\verilated.cpp" "'+$env:VERILATOR_ROOT+'\include\verilated_threads.cpp" /Fe:sim\test_bmp_scale.exe /Fo:sim\obj_bmp_scale\'
 cmd /c $build
 if($LASTEXITCODE -ne 0){throw 'C++ failed'}
 & .\sim\test_bmp_scale.exe
 if($LASTEXITCODE -ne 0){throw 'Controls failed'}
} finally {Pop-Location}
