# repos-base

Cópia local e online dos repos mais interessantes, sempre na última versão.

## Como funciona

- `sources.txt` lista os repos, um por linha (`dono/nome`).
- `scripts/sync.sh` baixa a última versão de cada repo e copia para `repos/<dono>/<nome>`, sem o `.git`.
- `sources.lock` registra o commit exato de cada fonte na última sincronização.
- O GitHub Action `sync` roda todo dia às 06:00 UTC, ao editar `sources.txt` e pelo botão **Run workflow**.
- Se uma fonte for apagada ou ficar privada, a última cópia continua aqui.
- Arquivos acima de 95 MB são removidos, porque o GitHub bloqueia arquivos acima de 100 MB.

## Adicionar um repo

1. Adicione `dono/nome` em `sources.txt`.
2. Faça commit e push. O Action sincroniza na hora.

## Cópia local

O clone fica em `F:\develop\repos-base`. A tarefa agendada `repos-base-pull` do Windows roda `git pull` todo dia e ao fazer logon.

## Fontes e licenças

Cada pasta em `repos/` mantém o arquivo de licença da fonte original. Confira a licença antes de adicionar um repo.
