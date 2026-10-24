# Creates a Windows scheduled task that runs scripts/update.sh every day and at logon.
# Usage: powershell -File scripts\schedule.ps1 [-Time 09:00] [-Name repos-base-update]
# To remove it: Unregister-ScheduledTask -TaskName repos-base-update -Confirm:$false
param(
  [string]$Time = "09:00",
  [string]$Name = "repos-base-update"
)

$root = Split-Path -Parent $PSScriptRoot
$bash = "C:\Program Files\Git\bin\bash.exe"
if (-not (Test-Path $bash)) { throw "Git Bash not found at $bash" }

$action = New-ScheduledTaskAction -Execute $bash `
  -Argument "-c `"cd '$($root.Replace('\','/'))' && bash scripts/update.sh >> update.log 2>&1`""
$triggers = @(
  (New-ScheduledTaskTrigger -Daily -At $Time),
  (New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME)
)
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 1)

Register-ScheduledTask -TaskName $Name -Action $action -Trigger $triggers -Settings $settings -Force | Out-Null
Write-Host "Task '$Name' created: every day at $Time and at logon."
