# Changelog

Shared memory across AI agent sessions. Every user-visible change gets one
line under `[Unreleased]` at the time it lands. Dated sections are cut only
on release/tag.

## [Unreleased]

- `feat`: Golden Gate macOS icon set for the menu bar — hand-drawn SF-style SVG icons (`ds/icons/macos/`, rendered through a new `MacIcon` component with runtime tinting) for Apple logo, wifi/ethernet, volume levels, mic-off, bluetooth (+headphones/phone/mouse/keyboard device icons), VPN key/sync, Spotlight magnifier, bell/bell-muted and Focus moon; battery is now a native macOS-shaped `MacBattery` indicator with level fill, low-battery red and charging bolt. All icons stay fully clickable with their existing popover actions.
- `feat`: Golden Gate phase 1 — macOS 27-style top menu bar: edge-to-edge light glass bar (28px),  + focused app + File/Edit/View/Go/Window/Help menus all wired to real actions (niri window management, thunar, swaylock/systemctl, cliphist, notify-send); Spotlight magnifier on the right, `Fri 10:01 AM` date format; search field moved inside the launcher (Spotlight). `Workspaces`/`ActiveWindow` dropped from the bar (IPC stays).
- `fix`: bar keyboard layout indicator uses a shared `Niri.kbLayoutShortName()` table (~60 languages + xkb code aliases) so any layout shows a 2-letter code (`tr`, `en`, `de`, ...) instead of `??`; unknown names fall back to first two letters.

## 2026-10-05 — Fresh start

- `chore`: re-initialized as a clean repo (`bariscodefxy/quickshell-config`)
  from the previous upstream-based base; single squashed history from here on.
- Baseline: Niri-specific shell (bar, launcher, notifications, popouts),
  Catppuccin Frappe tokens in `ds/Foundations.qml`, flake packaging with
  optional stylix rendering and home-manager module.
