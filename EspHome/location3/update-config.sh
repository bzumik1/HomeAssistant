#!/bin/sh
set -eu

TARGET_DIR="${TARGET_DIR:-/root/config/esphome}"
REPO_URL="https://github.com/bzumik1/HomeAssistant"
REF="main"
LOCATION="EspHome/location3"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

git clone --quiet --depth 1 --branch "$REF" "$REPO_URL" "$WORK_DIR"
mkdir -p "$TARGET_DIR"

secrets="$TARGET_DIR/secrets.yaml"
if [ -L "$secrets" ]; then
  if [ ! -e "$secrets" ]; then
    echo "Chyba: $secrets je symlink na neexistující soubor" >&2
    exit 1
  fi
  cp "$secrets" "$secrets.tmp"
  mv "$secrets.tmp" "$secrets"
  echo "secrets.yaml převeden ze symlinku na soubor"
fi

for src in "$WORK_DIR/$LOCATION"/*.yaml; do
  name="$(basename "$src")"
  [ "$name" = "secrets.yaml" ] && continue
  dest="$TARGET_DIR/$name"

  if [ -f "$dest" ] && [ ! -L "$dest" ] && ! grep -qF "url: $REPO_URL" "$dest"; then
    echo "Přeskočeno: $name je lokální soubor, ne odkaz na repo" >&2
    continue
  fi

  rm -f "$dest"
  cat > "$dest" <<EOF
packages:
  device:
    url: $REPO_URL
    ref: $REF
    files: [$LOCATION/$name]
    refresh: 0s
EOF
  echo "Odkaz: $name"
done

echo "Hotovo: zařízení z $LOCATION v $TARGET_DIR odkazují na $REPO_URL@$REF"
