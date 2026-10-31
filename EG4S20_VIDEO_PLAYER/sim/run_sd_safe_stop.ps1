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
 & "$env:VERILATOR_ROOT\bin\verilator_bin.exe" --cc --public-flat-rw --top-module sd_av_reader --Mdir sim/obj_sd_stop -Wno-fatal -GSAFE_STOP=1 rtl/sd_av_reader.v rtl/sd_bmp/spi_byte_master.v
 if($LASTEXITCODE -ne 0){throw 'Verilator failed'}
 $build='call "'+$VsDevCmd+'" -arch=x64 >nul && cl /nologo /EHsc /std:c++20 /O2 /I"'+$env:VERILATOR_ROOT+'\include" /I"'+$env:VERILATOR_ROOT+'\include\vltstd" /Isim\obj_sd_stop sim/test_sd_safe_stop.cpp sim\obj_sd_stop\*.cpp "'+$env:VERILATOR_ROOT+'\include\verilated.cpp" "'+$env:VERILATOR_ROOT+'\include\verilated_threads.cpp" /Fe:sim\test_sd_safe_stop.exe /Fo:sim\obj_sd_stop\'
 cmd /c $build
 if($LASTEXITCODE -ne 0){throw 'C++ failed'}
 & .\sim\test_sd_safe_stop.exe
 if($LASTEXITCODE -ne 0){throw 'SD safe stop failed'}
} finally {Pop-Location}
