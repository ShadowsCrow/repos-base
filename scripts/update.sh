#!/usr/bin/env bash
# Updates, on your machine, only the repos you chose.
# Usage:
#   scripts/update.sh                  # uses the list in update.txt
#   scripts/update.sh --all            # updates every source in sources.txt
#   scripts/update.sh owner/name ...   # updates only the given repos
# If a clone fails, the previous copy stays as it is.
set -uo pipefail

cd "$(dirname "$0")/.."
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

read_list() {
  sed 's/#.*//' "$1" | tr -d '\r' | awk 'NF {print $1}'
}

if [ "$#" -eq 0 ]; then
  if [ ! -f update.txt ]; then
    echo "Missing update.txt. Copy update.txt.example and choose the repos." >&2
    exit 1
  fi
  mapfile -t targets < <(read_list update.txt)
elif [ "$1" = "--all" ]; then
  mapfile -t targets < <(read_list sources.txt)
else
  targets=("$@")
fi

if [ "${#targets[@]}" -eq 0 ]; then
  echo "No repo to update." >&2
  exit 1
fi

touch update.lock
failed=0

for repo in "${targets[@]}"; do
  if ! read_list sources.txt | grep -qx "$repo"; then
    echo "WARNING: $repo is not in sources.txt, skipped." >&2
    failed=1
    continue
  fi

  echo "==> $repo"
  rm -rf "$TMP/src"
  # autocrlf=false keeps the source bytes on Windows too.
  case "$(uname -s)" in
    MINGW*|MSYS*|CYGWIN*)
      # Windows: skip names NTFS cannot store (", :, ?, *, <, >, |) and allow long paths.
      # Without this, a source such as ctresb/leis fails to check out.
      ok=1
      git -c core.autocrlf=false -c core.longpaths=true -c core.protectNTFS=false \
        clone --quiet --depth 1 --no-checkout "https://github.com/$repo" "$TMP/src" || ok=0
      if [ "$ok" = 1 ]; then
        git -C "$TMP/src" config core.autocrlf false
        git -C "$TMP/src" config core.longpaths true
        git -C "$TMP/src" config core.protectNTFS false
        git -C "$TMP/src" sparse-checkout set --no-cone '/*' '!*"*' '!*:*' '!*[?]*' '!*[*]*' '!*<*' '!*>*' '!*|*' '!*~[0-9]*' || ok=0
        [ "$ok" = 1 ] && { git -C "$TMP/src" checkout --quiet || ok=0; }
      fi
      ;;
    *)
      git -c core.autocrlf=false clone --quiet --depth 1 "https://github.com/$repo" "$TMP/src"
      ok=$([ $? -eq 0 ] && echo 1 || echo 0)
      ;;
  esac
  if [ "$ok" != 1 ]; then
    echo "WARNING: clone failed, keeping the previous copy of $repo" >&2
    failed=1
    continue
  fi

  sha="$(git -C "$TMP/src" rev-parse HEAD)"
  rm -rf "$TMP/src/.git"
  rm -rf "repos/$repo"
  mkdir -p "repos/$(dirname "$repo")"
  mv "$TMP/src" "repos/$repo"

  grep -v "^$repo " update.lock > "$TMP/lock" || true
  echo "$repo $sha $(date -u +%FT%TZ)" >> "$TMP/lock"
  sort "$TMP/lock" > update.lock
done

exit $failed
