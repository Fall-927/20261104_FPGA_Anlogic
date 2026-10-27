param(
    [Parameter(Mandatory = $true)][string]$VivadoBin,
    [Parameter(Mandatory = $true)][string]$TdRoot
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$model = Join-Path $TdRoot 'sim\eg\eg_phy_pll.v'
foreach ($tool in @('xvlog.bat', 'xelab.bat', 'xsim.bat')) {
    if (-not (Test-Path -LiteralPath (Join-Path $VivadoBin $tool))) {
        throw "Missing simulator tool: $tool"
    }
}
if (-not (Test-Path -LiteralPath $model)) { throw "Missing TD PLL model: $model" }
$workDir = Join-Path $repoRoot 'simulation'
New-Item -ItemType Directory -Force -Path $workDir | Out-Null

function Invoke-SimTool([string]$Tool, [string[]]$ToolArgs) {
    & (Join-Path $VivadoBin $Tool) @ToolArgs
    if ($LASTEXITCODE -ne 0) { throw "$Tool failed ($LASTEXITCODE)" }
}

Push-Location $workDir
try {
    Invoke-SimTool 'xvlog.bat' @('../rtl/video_480p_bars.v', '../sim/tb_video_480p.v', $model, '../rtl/hdmi_pll_480p.v', '../sim/tb_pll_480p.v')
    foreach ($test in @('tb_video_480p', 'tb_pll_480p')) {
        Invoke-SimTool 'xelab.bat' @($test, '-s', $test, '-mt', 'off')
        $result = & (Join-Path $VivadoBin 'xsim.bat') $test -tclbatch '../sim/run_all.tcl' 2>&1
        $result | Out-Host
        if ($LASTEXITCODE -ne 0 -or -not ($result -match 'PASS:') -or ($result -match 'Fatal:')) {
            throw "$test did not pass"
        }
    }
}
finally {
    Pop-Location
}
