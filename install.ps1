$ErrorActionPreference = "Stop"

$Root = $PSScriptRoot
$BinDir = Join-Path $env:USERPROFILE ".local\bin"
$ConfigDir = Join-Path $env:APPDATA "train"
$StateDir = Join-Path $env:LOCALAPPDATA "train"
$TrainPy = Join-Path $BinDir "train.py"
$TrainCmd = Join-Path $BinDir "train.cmd"
$ConfigFile = Join-Path $ConfigDir "config.json"

New-Item -ItemType Directory -Force -Path $BinDir, $ConfigDir, $StateDir | Out-Null

Copy-Item -Force (Join-Path $Root "train") $TrainPy
@'
@echo off
py -3 "%~dp0train.py" %*
'@ | Set-Content -Encoding ASCII -Path $TrainCmd

if (-not (Test-Path $ConfigFile)) {
    Copy-Item (Join-Path $Root "config.example.json") $ConfigFile
    Write-Host "Installed config -> $ConfigFile"
} else {
    Write-Host "Config exists, skipped: $ConfigFile"
}

Write-Host "Installed train -> $TrainCmd"
Write-Host ""
Write-Host "Add $BinDir to your PATH, then add to PowerShell profile:"
Write-Host '  if ($Host.Name -eq ''ConsoleHost'') { train }'
