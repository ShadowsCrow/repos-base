<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0f0c29,50:302b63,100:8e2de2&height=200&section=header&text=repos-base&fontSize=70&fontColor=ffffff&animation=fadeIn&fontAlignY=38&desc=Um%20kit%20de%20repos%20para%20ter%20sempre%20%C3%A0%20m%C3%A3o&descAlignY=60&descSize=20" alt="repos-base"/>

![Modelo](https://img.shields.io/badge/atualiza%C3%A7%C3%A3o-local%20e%20opcional-8e2de2?style=for-the-badge&labelColor=0f0c29)
![Sem Action](https://img.shields.io/badge/automa%C3%A7%C3%A3o-na%20sua%20m%C3%A1quina-8e2de2?style=for-the-badge&labelColor=0f0c29)
![Licença](https://img.shields.io/badge/fontes-MIT-8e2de2?style=for-the-badge&labelColor=0f0c29)

</div>

<br/>

## 💡 A ideia

O **repos-base** é um acervo de repositórios úteis. O repositório online guarda a **primeira versão** de cada um. Depois de clonar, **você escolhe** quais repos a sua máquina mantém atualizados.

O resultado é um kit de utilidades que funciona offline: prompts, listas de APIs, ferramentas e referências, tudo numa pasta só.

- **Nada roda no GitHub.** O repositório online não tem automação. Ele é só a base inicial.
- **Atualização por escolha.** Você lista em `atualizar.txt` os repos que quer manter na última versão.
- **Agendamento seu.** Você decide se o script roda todo dia, toda semana ou só quando você pedir.
- **Sem limite de tamanho no seu lado.** A atualização local não passa pelo limite de 100 MB por arquivo do GitHub.

<br/>

## 🔄 Como funciona

<div align="center">
  <img src="docs/fluxo.png" alt="Fluxo: repo online, clone único, atualizar.txt, atualizar.sh, repos originais, cópia local" width="900"/>
</div>

1. Você clona este repositório uma vez.
2. Você copia `atualizar.txt.exemplo` para `atualizar.txt` e deixa só os repos que quer atualizar.
3. O script `scripts/atualizar.sh` baixa a última versão de cada repo da lista.
4. O script troca a pasta `repos/<dono>/<nome>` pela versão nova, sem o `.git`.
5. O script grava o commit exato de cada repo em `atualizar.lock`.

Repos que não estão em `atualizar.txt` ficam na primeira versão. O arquivo `sources.lock` mostra o commit dessa primeira versão.

<br/>

## 🚀 Começar

```bash
git clone https://github.com/ShadowsCrow/repos-base.git
cd repos-base
cp atualizar.txt.exemplo atualizar.txt
```

Edite `atualizar.txt` e apague as linhas dos repos que você **não** quer atualizar. Depois rode:

```bash
bash scripts/atualizar.sh              # atualiza a lista de atualizar.txt
bash scripts/atualizar.sh --todos      # atualiza todas as fontes de sources.txt
bash scripts/atualizar.sh dono/nome    # atualiza só um repo
```

> Requisitos: `git` e `bash`. No Windows, use o Git Bash.

<br/>

## ⏰ Automatizar na sua máquina

**Windows:** crie a tarefa agendada com o script pronto. Ela roda todo dia às 09:00 e ao fazer logon.

```powershell
powershell -File scripts\agendar.ps1 -Hora 09:00
```

**Linux e macOS:** adicione uma linha no `crontab -e`.

```cron
0 9 * * * cd /caminho/para/repos-base && bash scripts/atualizar.sh >> atualizar.log 2>&1
```

O log fica em `atualizar.log`. Para parar a automação, remova a tarefa ou a linha do cron.

<br/>

## 📦 O que tem no acervo

| Repositório | O que é | Licença |
|---|---|---|
| [yihui-dev/awesome-opus5-5-videos](https://github.com/yihui-dev/awesome-opus5-5-videos) | 703 prompts de vídeos feitos com o Claude Opus 5.5. | MIT |
| [public-apis/public-apis](https://github.com/public-apis/public-apis) | Lista coletiva de APIs gratuitas. | MIT |
| [morluto/rea](https://github.com/morluto/rea) | Engenharia reversa com agentes, do comportamento de apps até binários nativos. | MIT |

Cada pasta em `repos/` mantém o arquivo de licença da fonte original.

<br/>

## ➕ Adicionar um repo

1. Confira o tamanho e a licença do repo.
2. Adicione `dono/nome` em `sources.txt`, uma fonte por linha.
3. Adicione a mesma linha em `atualizar.txt`, se quiser que a sua máquina atualize esse repo.
4. Rode `bash scripts/atualizar.sh dono/nome` para baixar a primeira cópia.

Só entram em `atualizar.txt` os repos que estão em `sources.txt`.

<br/>

## 🗂️ Estrutura

```text
repos-base/
├── sources.txt            # catálogo: repos que o acervo contém
├── sources.lock           # commit da primeira versão de cada repo
├── atualizar.txt.exemplo  # modelo da sua lista de atualização
├── atualizar.txt          # sua lista (local, fora do Git)
├── atualizar.lock         # commit de cada atualização local (fora do Git)
├── repos/<dono>/<nome>    # cópia de cada repo, sem .git
├── scripts/
│   ├── atualizar.sh       # atualiza os repos escolhidos
│   └── agendar.ps1        # cria a tarefa agendada no Windows
└── docs/                  # diagrama deste README
```

<br/>

## ⚠️ Cuidados

- **Não edite `repos/`.** A atualização substitui a pasta inteira do repo e apaga as suas mudanças.
- **Sem histórico.** A cópia é um instantâneo sem `.git`. Para ter o histórico de uma fonte, clone a fonte à parte.
- **Se uma fonte sumir,** o clone falha e a cópia anterior fica como está. O script mostra um aviso.

<br/>

## ⚖️ Licenças

Os repositórios do acervo pertencem aos autores originais e seguem as licenças deles. Este repositório só guarda cópias para uso pessoal.

<br/>

<div align="center">

Feito por [**ShadowsCrow**](https://github.com/ShadowsCrow) · Tech Lead SRE AI & Automação

⭐ Se o acervo ajudou, deixe uma estrela no repositório.

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:8e2de2,50:302b63,100:0f0c29&height=120&section=footer" alt="Rodapé"/>

</div>
