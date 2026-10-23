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

## Repos grandes (fork + clone)

Repos grandes demais para copiar em `repos/` ficam em `forks.txt`, como fork no GitHub e clone local raso.

| Fork | Original | Pasta local |
|---|---|---|
| [ShadowsCrow/leis](https://github.com/ShadowsCrow/leis) | [ctresb/leis](https://github.com/ctresb/leis) | `F:\develop\leis-br` |

A tarefa agendada `repos-base-forks` roda `scripts/update-forks.ps1` todo dia às 09:15 e no logon. O script:

1. roda `gh repo sync` no fork. Se o original for apagado, o fork fica como está;
2. roda `git pull` no clone local. Se o original reescrever o histórico, o clone é realinhado com o fork.

O log fica em `.git\update-forks.log`. Essa atualização depende do PC ligado.

## Fontes e licenças

Cada pasta em `repos/` mantém o arquivo de licença da fonte original. Confira a licença antes de adicionar um repo.
