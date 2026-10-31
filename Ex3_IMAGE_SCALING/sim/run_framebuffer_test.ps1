param(
 [Parameter(Mandatory=$true)][string]$VerilatorRoot,
 [string]$VsDevCmd='D:\Visual Studio\18\Community\Common7\Tools\VsDevCmd.bat'
)
$ErrorActionPreference='Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
 $env:VERILATOR_ROOT=$VerilatorRoot
 & "$VerilatorRoot\bin\verilator_bin.exe" --cc --top-module slideshow_framebuffer --Mdir sim/obj_framebuffer -Wno-fatal rtl/sdram/slideshow_framebuffer.v al_ip/SOFTFIFO.v sim/slideshow_memory_model.v
 if($LASTEXITCODE -ne 0){throw 'Verilator failed'}
 $build='call "'+$VsDevCmd+'" -arch=x64 >nul && cl /nologo /EHsc /std:c++20 /O2 /I"'+$VerilatorRoot+'\include" /I"'+$VerilatorRoot+'\include\vltstd" /Isim\obj_framebuffer sim\test_framebuffer.cpp sim\obj_framebuffer\*.cpp "'+$VerilatorRoot+'\include\verilated.cpp" "'+$VerilatorRoot+'\include\verilated_threads.cpp" /Fe:sim\test_framebuffer.exe /Fo:sim\obj_framebuffer\'
 cmd /c $build
 if($LASTEXITCODE -ne 0){throw 'C++ compilation failed'}
 & .\sim\test_framebuffer.exe
 if($LASTEXITCODE -ne 0){throw 'Framebuffer test failed'}
}finally{Pop-Location}
