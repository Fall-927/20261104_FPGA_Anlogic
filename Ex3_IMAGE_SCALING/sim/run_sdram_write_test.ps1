param(
 [Parameter(Mandatory=$true)][string]$VerilatorRoot,
 [string]$VsDevCmd='D:\Visual Studio\18\Community\Common7\Tools\VsDevCmd.bat'
)
$ErrorActionPreference='Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
 $env:VERILATOR_ROOT=$VerilatorRoot
 & "$VerilatorRoot\bin\verilator_bin.exe" --cc --top-module sdram_write_path_tb --Mdir sim/obj_sdram_write -Wno-fatal -Irtl/sdram sim/sdram_write_path_tb.v al_ip/SOFTFIFO.v rtl/sdram/sdram_controller_ref.v rtl/sdram/sdram_ctrl_ref.v rtl/sdram/sdram_cmd_ref.v rtl/sdram/sdram_data_ref.v
 if($LASTEXITCODE -ne 0){throw 'Verilator failed'}
 $build='call "'+$VsDevCmd+'" -arch=x64 >nul && cl /nologo /EHsc /std:c++20 /O2 /I"'+$VerilatorRoot+'\include" /I"'+$VerilatorRoot+'\include\vltstd" /Isim\obj_sdram_write sim\test_sdram_write.cpp sim\obj_sdram_write\*.cpp "'+$VerilatorRoot+'\include\verilated.cpp" "'+$VerilatorRoot+'\include\verilated_threads.cpp" /Fe:sim\test_sdram_write.exe /Fo:sim\obj_sdram_write\'
 cmd /c $build
 if($LASTEXITCODE -ne 0){throw 'C++ compilation failed'}
 & .\sim\test_sdram_write.exe
 if($LASTEXITCODE -ne 0){throw 'SDRAM write test failed'}
}finally{Pop-Location}
