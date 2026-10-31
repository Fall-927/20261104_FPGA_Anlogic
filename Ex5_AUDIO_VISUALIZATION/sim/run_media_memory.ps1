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
 & "$env:VERILATOR_ROOT\bin\verilator_bin.exe" --cc --top-module av15_memory --Mdir sim/obj_media_memory -Wno-fatal -Wno-PINMISSING -Wno-TIMESCALEMOD -GCOMBINED=1 rtl/av15_memory.v al_ip/SOFTFIFO.v sim/video_memory_model.v
 if($LASTEXITCODE -ne 0){throw 'Verilator failed'}
 $build='call "'+$VsDevCmd+'" -arch=x64 >nul && cl /nologo /EHsc /std:c++20 /O2 /I"'+$env:VERILATOR_ROOT+'\include" /I"'+$env:VERILATOR_ROOT+'\include\vltstd" /Isim\obj_media_memory sim/test_media_memory.cpp sim\obj_media_memory\*.cpp "'+$env:VERILATOR_ROOT+'\include\verilated.cpp" "'+$env:VERILATOR_ROOT+'\include\verilated_threads.cpp" /Fe:sim\test_media_memory.exe /Fo:sim\obj_media_memory\'
 cmd /c $build
 if($LASTEXITCODE -ne 0){throw 'C++ failed'}
 & .\sim\test_media_memory.exe
 if($LASTEXITCODE -ne 0){throw 'Memory failed'}
} finally {Pop-Location}
