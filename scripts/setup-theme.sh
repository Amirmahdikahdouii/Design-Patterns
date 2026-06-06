#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_DIR="$ROOT/website/themes/hugo-book"
THEME_VERSION="v0.14.0"

if [[ -d "$THEME_DIR/.git" ]]; then
  echo "Hugo Book theme already installed at $THEME_DIR"
  exit 0
fi

mkdir -p "$ROOT/website/themes"
git clone --depth 1 --branch "$THEME_VERSION" \
  https://github.com/alex-shpak/hugo-book.git "$THEME_DIR"
echo "Installed Hugo Book $THEME_VERSION at $THEME_DIR"
