[CmdletBinding()]
param(
    [int]$IntervalMinutes = 50,
    [string]$TaskName = "StandUpWaterAgent",
    [switch]$StartNow
)

$ErrorActionPreference = "Stop"

if ($IntervalMinutes -lt 1) {
    throw "IntervalMinutes must be at least 1."
}

$scriptPath = Join-Path $PSScriptRoot "StandUpWaterAlarm.ps1"
if (-not (Test-Path -LiteralPath $scriptPath)) {
    throw "Could not find reminder script at $scriptPath"
}

$powershellPath = (Get-Command powershell.exe).Source
$taskArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""

$action = New-ScheduledTaskAction -Execute $powershellPath -Argument $taskArgs
$trigger = New-ScheduledTaskTrigger `
    -Once `
    -At (Get-Date).AddMinutes($IntervalMinutes) `
    -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes) `
    -RepetitionDuration (New-TimeSpan -Days 3650)

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -MultipleInstances IgnoreNew `
    -StartWhenAvailable

$principalUser = if ($env:USERDOMAIN) { "$env:USERDOMAIN\$env:USERNAME" } else { $env:USERNAME }
$principal = New-ScheduledTaskPrincipal `
    -UserId $principalUser `
    -LogonType Interactive `
    -RunLevel Limited

Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Description "Every $IntervalMinutes minutes, reminds you to stand up and drink water." `
    -Force | Out-Null

if ($StartNow) {
    Start-ScheduledTask -TaskName $TaskName
}

Write-Host "Installed scheduled task '$TaskName'."
Write-Host "Reminder interval: every $IntervalMinutes minutes."
Write-Host "Reminder script: $scriptPath"
