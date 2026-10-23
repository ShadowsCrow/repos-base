# Atualiza cada fork de forks.txt a partir do repo original e depois atualiza o clone local.
# O fork e o clone são espelhos: não faça commits neles.
$ErrorActionPreference = 'Continue'
$root = Split-Path $PSScriptRoot -Parent
$log = Join-Path $root '.git\update-forks.log'

function Write-Log($msg) {
    "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $msg" | Out-File -FilePath $log -Append -Encoding utf8
}

foreach ($line in Get-Content (Join-Path $root 'forks.txt') -Encoding utf8) {
    $line = ($line -replace '#.*', '').Trim()
    if (-not $line) { continue }
    $fork, $dir = $line -split '\s+', 2

    # 1. Fork no GitHub. Se o original foi apagado, o sync falha e o fork fica como está.
    gh repo sync $fork *> $null
    if ($LASTEXITCODE -ne 0) {
        # O original reescreveu o histórico. O fork é espelho, então segue o original.
        gh repo sync $fork --force *> $null
        if ($LASTEXITCODE -eq 0) { Write-Log "$fork sincronizado com --force" }
        else { Write-Log "ERRO: sync do fork $fork falhou; fork mantido como está" }
    }

    # 2. Clone local, raso (sem histórico antigo).
    if (-not (Test-Path (Join-Path $dir '.git'))) { Write-Log "ERRO: clone $dir não existe"; continue }
    git -C $dir pull --ff-only --quiet *> $null
    if ($LASTEXITCODE -ne 0) {
        git -C $dir fetch --depth 1 --quiet origin *> $null
        if ($LASTEXITCODE -eq 0) {
            $branch = git -C $dir rev-parse --abbrev-ref HEAD
            git -C $dir reset --hard --quiet "origin/$branch" *> $null
            Write-Log "$dir realinhado com origin/$branch"
        } else { Write-Log "ERRO: fetch de $dir falhou; clone mantido como está" }
    }
    Write-Log "$fork ok: $(git -C $dir log -1 --format='%h %cs %s')"
}
