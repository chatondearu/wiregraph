#!/usr/bin/env bash
# Run the full stack in dev mode: Vite (via Tauri) + native shell.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ ! -d node_modules ]]; then
  echo "wiregraph: node_modules missing — run npm install from the repo root" >&2
  exit 1
fi

if ! command -v cargo >/dev/null 2>&1; then
  echo "wiregraph: cargo not found — use nix develop or install a Rust toolchain" >&2
  exit 1
fi

cd src-tauri
exec cargo tauri dev
