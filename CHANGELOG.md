# Changelog

Shared memory across AI agent sessions. Every user-visible change gets one
line under `[Unreleased]` at the time it lands. Dated sections are cut only
on release/tag.

## [Unreleased]

- `fix`: menu-bar dropdowns are clickable now — the shell input mask used `Subtract` for panel regions, which per quickshell source can never add clickable areas (only the bar strip worked; dock/popouts/launcher clicks below it were dead too). Regions are now `Combine`, and the open menu unions its measured geometry in. Menus also dismiss when app focus changes, since empty-area clicks pass through to apps.
- `feat`: app-specific File/Go menus — File and Go rebuild from the focused app (browser: new/incognito window, history, bookmarks…; terminal/editor: new window, open folder…; chat/media/files: matching folders and actions); app-menu Quit now closes all of the app's windows. Note: Wayland has no menubar-export protocol, so items are per-app action maps, not the app's internal menus.
- `feat`: liquid-glass menu bar + dropdowns — frosted base with top-down sheen, specular top edge, drop shadow and rounded (12px) menus with taller items; bar/menu opacity floors raised since no compositor blur is available. All left menus (/app/File/Edit/View/Go/Window/Help) verified against real binaries and niri actions.
- `fix`: disable compositor background blur (layer-rule removed) — it stopped app windows from rendering; shell keeps its tinted-glass look without blur until a safe alternative is found. Shell namespace temporarily `quickshell-drawers-test`, revert after relogin.
- `feat`: macOS-style dock — bottom-centered glass pill with pinned apps (persisted), live running apps with indicator dots, cursor magnification, tooltips, right-click menu (Focus/Open, Quit, Keep/Remove), System Settings shortcut and Trash; windows underneath respect a bottom exclusion zone.
- `feat`: wallpaper management in System Settings — new Wallpaper page with thumbnail grid from `~/Pictures/Wallpapers`, fill/fit mode, rescan and folder creation; applies with a macOS-style crossfade via `awww` (successor of `swww`) and restores the last wallpaper on login. Requires the `swww` nixpkgs package (provides the `awww` binaries; added to the flake wrapper PATH, bare runs need it in system packages or `nix profile`).
- `feat`: macOS dark scheme pass — palette moved from Catppuccin Frappe to macOS dark neutrals (near-white text, `#0a84ff` accent, system red/orange/green), switches default to macOS green; Settings gained colorful icon tiles and grouped card rows with separators like the reference screenshot. Verified live via screenshots.
- `feat`: macOS-style System Settings window — dark frosted window with traffic lights (close/minimize/zoom all work), searchable sidebar (Wi-Fi, Bluetooth, VPN, Battery, General, Appearance, Menu Bar, Sound, Keyboard, Notifications, Focus), back/forward history and detail pages that reuse the real control panels. New Appearance page hosts the Golden Gate Liquid Glass transparency slider; Menu Bar page toggles every bar icon plus 12/24-hour clock. Backed by a new JSON-persisted `Settings` service (`~/.config/qsc/settings.json`), openable from  → System Settings… or `qs-ipc settings toggle`.
- `feat`: bar popovers now open on click instead of hover — every status icon (audio, keyboard layout, network, VPN, bluetooth, battery) and tray icon with a menu toggles its control panel on click; tray icons without a menu still activate directly. Direct one-click toggles moved into their popovers (volume/mute, wifi switch, VPN switches, layout list, bluetooth adapter).
- `feat`: Golden Gate macOS icon set for the menu bar — hand-drawn SF-style SVG icons (`ds/icons/macos/`, rendered through a new `MacIcon` component with runtime tinting) for Apple logo, wifi/ethernet, volume levels, mic-off, bluetooth (+headphones/phone/mouse/keyboard device icons), VPN key/sync, Spotlight magnifier, bell/bell-muted and Focus moon; battery is now a native macOS-shaped `MacBattery` indicator with level fill, low-battery red and charging bolt. All icons stay fully clickable with their existing popover actions.
- `feat`: Golden Gate phase 1 — macOS 27-style top menu bar: edge-to-edge light glass bar (28px),  + focused app + File/Edit/View/Go/Window/Help menus all wired to real actions (niri window management, thunar, swaylock/systemctl, cliphist, notify-send); Spotlight magnifier on the right, `Fri 10:01 AM` date format; search field moved inside the launcher (Spotlight). `Workspaces`/`ActiveWindow` dropped from the bar (IPC stays).
- `fix`: bar keyboard layout indicator uses a shared `Niri.kbLayoutShortName()` table (~60 languages + xkb code aliases) so any layout shows a 2-letter code (`tr`, `en`, `de`, ...) instead of `??`; unknown names fall back to first two letters.

## 2026-10-05 — Fresh start

- `chore`: re-initialized as a clean repo (`bariscodefxy/quickshell-config`)
  from the previous upstream-based base; single squashed history from here on.
- Baseline: Niri-specific shell (bar, launcher, notifications, popouts),
  Catppuccin Frappe tokens in `ds/Foundations.qml`, flake packaging with
  optional stylix rendering and home-manager module.
