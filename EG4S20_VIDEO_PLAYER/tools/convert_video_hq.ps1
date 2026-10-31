param(
 [Parameter(Mandatory=$true)][string]$InputVideo,
 [Parameter(Mandatory=$true)][string]$OutputBase,
 [string]$Ffmpeg='ffmpeg',
 [string]$Ffprobe='ffprobe'
)
$ErrorActionPreference='Stop'
$inputPath=(Resolve-Path -LiteralPath $InputVideo).Path
$base=[IO.Path]::GetFullPath($OutputBase)
$rgb="$base.rgb565"
$pcm="$base.pcm"
$av="$base.AV"
if((Test-Path -LiteralPath $rgb) -or (Test-Path -LiteralPath $pcm) -or (Test-Path -LiteralPath $av)){throw "Output exists; choose a new OutputBase or remove outputs deliberately."}
$json=& $Ffprobe -v error -show_entries format=duration:stream=codec_type,duration,channels,sample_rate -of json -- $inputPath | ConvertFrom-Json
$video=$json.streams | Where-Object codec_type -eq 'video' | Select-Object -First 1
$audio=$json.streams | Where-Object codec_type -eq 'audio' | Select-Object -First 1
if(!$video){throw 'Input has no video stream'}
if(!$audio){throw 'Input has no audio stream'}
$duration=[double]$video.duration
if($duration -le 0){$duration=[double]$json.format.duration}
if($duration -gt 2400){throw 'Video exceeds 40 minutes; split it into AV segments for this FPGA profile.'}
Write-Host ('Input duration: {0:N3}s, source audio: {1} Hz / {2} channel(s)' -f $duration,$audio.sample_rate,$audio.channels)
& $Ffmpeg -hide_banner -y -i $inputPath -map 0:v:0 -vf 'fps=10,scale=320:240:force_original_aspect_ratio=decrease:flags=lanczos,pad=320:240:(ow-iw)/2:(oh-ih)/2:black,setsar=1' -an -c:v rawvideo -pix_fmt rgb565le -f rawvideo $rgb
if($LASTEXITCODE){throw 'Video conversion failed'}
& $Ffmpeg -hide_banner -y -i $inputPath -map 0:a:0 -vn -ac 2 -ar 48000 -c:a pcm_s16le -f s16le $pcm
if($LASTEXITCODE){throw 'Audio conversion failed'}
& python "$PSScriptRoot\pack_video_hq.py" --video $rgb --audio $pcm --output $av
if($LASTEXITCODE){throw 'AV packing failed'}
$size=(Get-Item -LiteralPath $av).Length
Write-Host ('Created {0} ({1:N1} MB). F partition 500MB can hold roughly 4-5 minutes after existing files.' -f $av,($size/1MB))
