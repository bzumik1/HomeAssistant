#!/bin/sh
set -eu

TARGET_DIR="/root/config/esphome"
REPO_URL="https://github.com/bzumik1/HomeAssistant.git"
REPO_REL="HomeAssistant"
SOURCE_REL="$REPO_REL/EspHome/location3"
REPO_DIR="$TARGET_DIR/$REPO_REL"
SOURCE_DIR="$TARGET_DIR/$SOURCE_REL"
TEMPLATES_SRC_REL="$(basename "$TARGET_DIR")/$REPO_REL/EspHome/templates"
TEMPLATES_LINK="$(dirname "$TARGET_DIR")/templates"

mkdir -p "$TARGET_DIR"

if [ ! -d "$REPO_DIR/.git" ]; then
  git clone "$REPO_URL" "$REPO_DIR"
else
  git -C "$REPO_DIR" fetch --all --prune
  git -C "$REPO_DIR" pull --ff-only
fi

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Chyba: zdrojová složka $SOURCE_DIR neexistuje" >&2
  exit 1
fi

find "$SOURCE_DIR" -mindepth 1 -maxdepth 1 \
  ! -name '.git' \
  ! -name '.secrets' \
  ! -name 'HomeAssistant' \
  -print | while IFS= read -r src; do
  name="$(basename "$src")"
  dest="$TARGET_DIR/$name"
  rm -rf "$dest"
  ln -s "$SOURCE_REL/$name" "$dest"
done

if [ -L "$TEMPLATES_LINK" ] || [ ! -e "$TEMPLATES_LINK" ]; then
  ln -sfn "$TEMPLATES_SRC_REL" "$TEMPLATES_LINK"
else
  echo "Chyba: $TEMPLATES_LINK existuje a není symlink" >&2
  exit 1
fi

echo "Hotovo: na obsah $SOURCE_DIR byly vytvořeny symlinky v $TARGET_DIR"
