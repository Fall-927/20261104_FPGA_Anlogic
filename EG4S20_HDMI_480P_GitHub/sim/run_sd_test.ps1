param(
 [Parameter(Mandatory=$true)][string]$VerilatorRoot,
 [string]$VsDevCmd='D:\Visual Studio\18\Community\Common7\Tools\VsDevCmd.bat'
)
$ErrorActionPreference='Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
 $env:VERILATOR_ROOT=$VerilatorRoot
 & "$VerilatorRoot\bin\verilator_bin.exe" --cc --top-module sd_bmp_fixed_lba_reader -GSECTORS=2 --Mdir sim/obj_sd -Wno-fatal rtl/sd_bmp/spi_byte_master.v rtl/sd_bmp/sd_bmp_fixed_lba_reader.v
 if($LASTEXITCODE -ne 0){throw 'Verilator failed'}
 $build='call "'+$VsDevCmd+'" -arch=x64 >nul && cl /nologo /EHsc /std:c++20 /O2 /I"'+$VerilatorRoot+'\include" /I"'+$VerilatorRoot+'\include\vltstd" /Isim\obj_sd sim\test_sd.cpp sim\obj_sd\*.cpp "'+$VerilatorRoot+'\include\verilated.cpp" "'+$VerilatorRoot+'\include\verilated_threads.cpp" /Fe:sim\test_sd.exe /Fo:sim\obj_sd\'
 cmd /c $build
 if($LASTEXITCODE -ne 0){throw 'C++ compilation failed'}
 & .\sim\test_sd.exe
 if($LASTEXITCODE -ne 0){throw 'SD test failed'}
}finally{Pop-Location}
