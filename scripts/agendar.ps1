# Cria uma tarefa agendada do Windows que roda scripts/atualizar.sh todo dia e ao fazer logon.
# Uso: powershell -File scripts\agendar.ps1 [-Hora 09:00] [-Nome repos-base-atualizar]
# Para remover: Unregister-ScheduledTask -TaskName repos-base-atualizar -Confirm:$false
param(
  [string]$Hora = "09:00",
  [string]$Nome = "repos-base-atualizar"
)

$raiz = Split-Path -Parent $PSScriptRoot
$bash = "C:\Program Files\Git\bin\bash.exe"
if (-not (Test-Path $bash)) { throw "Git Bash não encontrado em $bash" }

$acao = New-ScheduledTaskAction -Execute $bash `
  -Argument "-c `"cd '$($raiz.Replace('\','/'))' && bash scripts/atualizar.sh >> atualizar.log 2>&1`""
$gatilhos = @(
  (New-ScheduledTaskTrigger -Daily -At $Hora),
  (New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME)
)
$config = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 1)

Register-ScheduledTask -TaskName $Nome -Action $acao -Trigger $gatilhos -Settings $config -Force | Out-Null
Write-Host "Tarefa '$Nome' criada: todo dia às $Hora e ao fazer logon."
