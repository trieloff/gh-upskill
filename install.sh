#!/usr/bin/env bash
set -Eeo pipefail
IFS=$'\n\t'

REPO="trieloff/upskill"
RAW_ROOT="https://raw.githubusercontent.com/${REPO}/main"

usage() {
  cat <<USAGE
Install upskill locally.

Usage:
  curl -fsSL https://raw.githubusercontent.com/${REPO}/main/install.sh | bash

Options:
  --prefix <dir>     Install prefix (default: /usr/local or ~/.local)
  --bin-dir <dir>    Install bin dir (default: <prefix>/bin)
  -h, --help         Show help
USAGE
}

PREFIX=""
BIN_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix) PREFIX="$2"; shift 2 ;;
    --bin-dir) BIN_DIR="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$PREFIX" ]]; then
  if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
    PREFIX="/usr/local"
  else
    PREFIX="$HOME/.local"
  fi
fi

if [[ -z "$BIN_DIR" ]]; then
  BIN_DIR="$PREFIX/bin"
fi

mkdir -p "$BIN_DIR"

echo "Installing to $BIN_DIR ..."
for f in upskill gh-upskill; do
  curl -fsSL "$RAW_ROOT/$f" -o "$BIN_DIR/$f"
  chmod +x "$BIN_DIR/$f"
  echo "Installed $BIN_DIR/$f"
done

echo "Done. Ensure $BIN_DIR is on your PATH."

