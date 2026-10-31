param(
 [string]$VerilatorRoot='C:\Users\yushe\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\Lib\site-packages\verilator',
 [string]$VsDevCmd='D:\Visual Studio\18\Community\Common7\Tools\VsDevCmd.bat'
)
$ErrorActionPreference='Stop'
Push-Location (Split-Path -Parent $PSScriptRoot)
try {
 $env:VERILATOR_ROOT=$VerilatorRoot
 $cases=@(
  @{Top='av15_unpack';Test='sim/test_av15_unpack.cpp';Sources=@('rtl/av15_unpack.v')},
  @{Top='video_player_tb';Test='sim/test_video_player.cpp';Sources=@('sim/video_player_tb.v','sim/video_memory_model.v','rtl/hdmi_video_top.v','rtl/av15_memory.v','rtl/av15_unpack.v','rtl/video_controls.v','rtl/video_480p_bars.v','rtl/hdmi_audio_tx.v','rtl/tmds_encoder.v','al_ip/SOFTFIFO.v')}
 )
 foreach($case in $cases){
  $obj='sim/obj_'+$case.Top
  New-Item -ItemType Directory -Force -Path $obj | Out-Null
  $profileArgs=if($case.Top -eq 'av15_unpack'){@('-GHQ=0','-GLOOP=0')}else{@()}
  & "$VerilatorRoot\bin\verilator_bin.exe" --cc --top-module $case.Top --Mdir $obj -Wno-fatal -Wno-PINMISSING -Wno-TIMESCALEMOD @profileArgs @($case.Sources)
  if($LASTEXITCODE -ne 0){throw 'Verilator failed'}
  $objWin=$obj.Replace('/','\')
  $build='call "'+$VsDevCmd+'" -arch=x64 >nul && cl /nologo /EHsc /std:c++20 /O2 /DNDEBUG /I"'+$VerilatorRoot+'\include" /I"'+$VerilatorRoot+'\include\vltstd" /I'+$objWin+' '+$case.Test+' '+$objWin+'\*.cpp "'+$VerilatorRoot+'\include\verilated.cpp" "'+$VerilatorRoot+'\include\verilated_threads.cpp" /Fe:sim\test_'+$case.Top+'.exe /Fo:'+ $objWin+'\'
  cmd /c $build
  if($LASTEXITCODE -ne 0){throw 'C++ build failed'}
  & ('.\sim\test_'+$case.Top+'.exe')
  if($LASTEXITCODE -ne 0){throw ($case.Top+' regression failed')}
  if($case.Top -eq 'video_player_tb'){
   & .\sim\test_video_player_tb.exe --pause
   if($LASTEXITCODE -ne 0){throw 'Pause/resume regression failed'}
   & .\sim\test_video_player_tb.exe --switch
   if($LASTEXITCODE -ne 0){throw 'Switch regression failed'}
  }
 }
} finally {Pop-Location}
