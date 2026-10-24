#!/usr/bin/env bash
# Atualiza, na sua máquina, só os repos que você escolheu.
# Uso:
#   scripts/atualizar.sh                  # usa a lista de atualizar.txt
#   scripts/atualizar.sh --todos          # atualiza todas as fontes de sources.txt
#   scripts/atualizar.sh dono/nome ...    # atualiza só os repos indicados
# Se o clone falhar, a cópia anterior fica como está.
set -uo pipefail

cd "$(dirname "$0")/.."
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

ler_lista() {
  sed 's/#.*//' "$1" | tr -d '\r' | awk 'NF {print $1}'
}

if [ "$#" -eq 0 ]; then
  if [ ! -f atualizar.txt ]; then
    echo "Falta atualizar.txt. Copie atualizar.txt.exemplo e escolha os repos." >&2
    exit 1
  fi
  mapfile -t alvos < <(ler_lista atualizar.txt)
elif [ "$1" = "--todos" ]; then
  mapfile -t alvos < <(ler_lista sources.txt)
else
  alvos=("$@")
fi

if [ "${#alvos[@]}" -eq 0 ]; then
  echo "Nenhum repo para atualizar." >&2
  exit 1
fi

touch atualizar.lock
falhou=0

for repo in "${alvos[@]}"; do
  if ! ler_lista sources.txt | grep -qx "$repo"; then
    echo "AVISO: $repo não está em sources.txt, ignorado." >&2
    falhou=1
    continue
  fi

  echo "==> $repo"
  rm -rf "$TMP/src"
  # autocrlf=false mantém os bytes da fonte também no Windows.
  if ! git -c core.autocrlf=false clone --quiet --depth 1 "https://github.com/$repo" "$TMP/src"; then
    echo "AVISO: clone falhou, mantendo a cópia anterior de $repo" >&2
    falhou=1
    continue
  fi

  sha="$(git -C "$TMP/src" rev-parse HEAD)"
  rm -rf "$TMP/src/.git"
  rm -rf "repos/$repo"
  mkdir -p "repos/$(dirname "$repo")"
  mv "$TMP/src" "repos/$repo"

  grep -v "^$repo " atualizar.lock > "$TMP/lock" || true
  echo "$repo $sha $(date -u +%FT%TZ)" >> "$TMP/lock"
  sort "$TMP/lock" > atualizar.lock
done

exit $falhou
