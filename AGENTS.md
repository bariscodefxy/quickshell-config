# AGENTS.md

Quickshell (Qt6/QML) desktop shell config for Niri, packaged as a Nix flake.
Entry point: `shell.qml` → `shell/Shell.qml` (one instance per screen).

## Run & verify

- `nix flake check` — the only automated check (CI runs it on `main` + PRs). It builds the default package.
- Manual run: `quickshell -p ./` from repo root. No test suite, no linter.
- There is no `quickshell` dev shell here; QML errors surface at runtime in the compositor session.

## Two config layers — edit the right one

| Mode | Command | Foundations.qml source | `*.json` source | Fonts/PATH |
|---|---|---|---|---|
| Raw | `quickshell -p ./` | committed `ds/Foundations.qml` | files in repo root | system fonts + PATH only |
| Wrapped | `quickshell-config` | **rendered from `ds/Foundations.qml.template`** when `stylix` option is set, else the committed file | injected from `*Path` options, else repo files | bundles material-symbols, `cliphist`, `wl-clipboard` |

Consequences:

- Theme/token edits usually belong in `ds/Foundations.qml.template`, not the committed `ds/Foundations.qml` — the latter is overwritten by the template whenever `stylix` is set (see `installPhase` in `flake.nix`). If `stylix` is null, the committed file is used as-is.
- `bin/qs-ipc` / `bin/qs-toggle-launcher` contain `@PLACEHOLDERS@` substituted only in the packaged build. Never edit the output of `result/` or `~/.nix-profile`; edit `bin/` sources.
- IPC instances are keyed by md5 of the resolved `shell.qml` path: an IPC call only reaches the instance started from the same resolved path. Route through the same wrapper binary the shell was started with. Handlers/targets live in `services/IpcHandler.qml`.

## Fonts

UI text is Apple's **SF Pro Text** (`Foundations.font.family.sans`); mono is **MesloLGS Nerd Font**. SF fonts come from the `apple-fonts.nix` flake input in `~/nix-config` (system-wide fontconfig default) — raw mode needs them installed locally. Bar/launcher icons need **Material Symbols Rounded** plus a Nerd Font. The wrapper symlinks material-symbols and exports it via `XDG_DATA_DIRS`; raw mode relies on system fonts. If icons render as text or tofu, check `fc-match "Material Symbols Rounded"` first; if UI text falls back wrong, check `fc-match "SF Pro Text"`.

## Layout

- `shell/` — per-screen window, background/border, panel visibility plumbing.
- `modules/bar/` — top bar; `modules/launcher/` — app/command/clipboard/KeePassXC launcher (`services/` subdir holds its backends); `modules/notifications/`; `modules/popups/` — bar popovers.
- `services/` — app-wide QML singletons (audio, network, Niri IPC via `niri msg`, notifications, ...). This shell is Niri-specific; do not add other-compositor APIs without discussion.
- `ds/` — design tokens (`Foundations.qml`: palette, spacing, radius, fonts) + reusable components.

## QML conventions in this repo

- New components: start with `pragma ComponentBehavior: Bound`.
- Singletons: `pragma Singleton` + `Singleton {}` (see `ds/Foundations.qml`, `services/*.qml`).
- `import qs.<dir>` maps to the matching top-level directory (`qs.ds` → `ds/`).

## Workflow

- Conventional commits with `feat:` / `fix:` / `chore:` prefixes, on `main`.
- `keepass.json` (age identity + encrypted password for the KeePassXC launcher) is a secret: never commit a real one, never print its contents. The build tolerates its absence (writes `{}`).
- After any user-visible change, append a line under `## [Unreleased]` in `CHANGELOG.md` — it is the shared memory across agent sessions. Move entries to a dated section only when cutting a release/tag. `CHANGELOG.md` is always kept in English.
- Compositor, system theme, fonts, and portal config live in `~/nix-config`, not here. Changes that only take effect there (rebuild/switch/relogin) must be called out explicitly.
