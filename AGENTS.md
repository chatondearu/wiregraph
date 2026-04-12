# AGENTS.md — wiregraph

Guidance for agentic tools when this directory is the workspace root.

## Nix (this repo)

This project ships a **standalone flake** at the repo root (`flake.nix` + `flake.lock`).

- **Dev environment**: `nix develop` — Rust, Node.js, `cargo-tauri`, GTK/WebKitGTK, OpenSSL (`OPENSSL_NO_VENDOR`), GStreamer plugin path (same idea as the release wrapper), `pipewire` + `alsa-utils` on `PATH`.
- **Release build**: `nix build .#wiregraph` (or `.#default`) — wraps [`default.nix`](default.nix) via `callPackage`.
- **Linux only** in flake outputs: `x86_64-linux`, `aarch64-linux` (matches package `meta.platforms`).

Typical dev flow inside the shell: `npm install`, then `cd src-tauri && cargo tauri dev`.

### Parent monorepo (optional)

If this tree is still vendored under a larger flake, that repo may re-export or pin this package; local work still uses `nix develop` here when this folder is the workspace root.

## What this is

Desktop app: **Tauri 2** (Rust) + **Vue 3** + **Vue Flow** — visual PipeWire graph (nodes / ports / links), optional ALSA correlation, `pw-link` connect/disconnect via IPC.

## Layout

| Path | Role |
|------|------|
| `src/` | Vue 3 UI (Vite), graph components (`components/FlowGraph.vue`, `SwitchboardNode.vue`, …) |
| `src/pwTypes.ts`, `src/pwParse.ts` | PipeWire model types; parsing helpers if used |
| `src-tauri/` | Rust crate, Tauri commands, `pw-dump` / graph building |
| `default.nix` | Nix package: `cargo-tauri build`, npm fetch, runtime wrap |

## Build and dev

### Local (with Tauri CLI + system deps)

- Frontend typecheck + bundle: `npm install && npm run build`
- Full app dev (needs WebKitGTK, etc.): `npm run dev` in `src-tauri` context per Tauri docs, or use `cargo tauri dev` from `src-tauri`

### Nix package (authoritative release build)

From this directory:

```sh
nix build .#wiregraph
```

After changing `package-lock.json`, update `fetchNpmDeps` hash in `default.nix`.

## Nix / Tauri gotchas (do not regress)

1. **Use `cargo-tauri build` for release**, not plain `cargo build` alone — otherwise the app can keep pointing at the Vite dev URL.
2. **GStreamer at runtime**: the wrapper sets `GST_PLUGIN_SYSTEM_PATH_1_0` (see `default.nix`); WebKit/media paths need `gst-plugins-base` / good plugins in that path.
3. **`pw-dump` compatibility**: avoid flags the user’s PipeWire lacks (e.g. `-R` on older installs).
4. **Large `pw-dump` JSON**: the UI should consume a **compact graph JSON** from a Tauri command (e.g. `get_pipewire_graph`) built in Rust — do not rely on shipping the full dump through IPC.
5. **`pw-dump` port direction** uses `"in"` / `"out"` (not only `"input"`); parsers must map both.

## UI notes

- Node layout in `FlowGraph.vue` stacks by column using **estimated heights** aligned with `SwitchboardNode.vue` CSS so tall nodes do not overlap.
- Vue: composable `<script setup>`, typed props; match existing style.

## Commits

Prefer [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.
