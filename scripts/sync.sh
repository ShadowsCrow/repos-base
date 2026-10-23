#!/usr/bin/env bash
# Copia a última versão de cada repo de sources.txt para repos/<dono>/<nome>.
# Se o clone de uma fonte falhar, a cópia anterior fica como está.
set -uo pipefail

cd "$(dirname "$0")/.."
MAX_BYTES=$((95 * 1024 * 1024))   # GitHub bloqueia arquivos acima de 100 MB
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

touch sources.lock
failed=0

while IFS= read -r line || [ -n "$line" ]; do
  repo="$(echo "$line" | sed 's/#.*//' | tr -d '[:space:]')"
  [ -z "$repo" ] && continue

  echo "==> $repo"
  rm -rf "$TMP/src"
  if ! git clone --quiet --depth 1 "https://github.com/$repo" "$TMP/src"; then
    echo "AVISO: clone falhou, mantendo a cópia anterior de $repo" >&2
    failed=1
    continue
  fi

  sha="$(git -C "$TMP/src" rev-parse HEAD)"
  rm -rf "$TMP/src/.git"
  find "$TMP/src" -type f -size +"${MAX_BYTES}c" -print -delete | sed 's/^/arquivo grande removido: /'

  rm -rf "repos/$repo"
  mkdir -p "repos/$(dirname "$repo")"
  mv "$TMP/src" "repos/$repo"

  grep -v "^$repo " sources.lock > "$TMP/lock" || true
  echo "$repo $sha $(date -u +%FT%TZ)" >> "$TMP/lock"
  sort "$TMP/lock" > sources.lock
done < sources.txt

exit $failed
