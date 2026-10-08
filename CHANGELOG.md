# Changelog

Shared memory across AI agent sessions. Every user-visible change gets one
line under `[Unreleased]` at the time it lands. Dated sections are cut only
on release/tag.

## [Unreleased]

- `feat`: dock slots stretch with magnification — a growing icon pushes neighbors aside instead of overlapping; pill breathes with it, pointer maps back to the grid so the right icon grows.

- `fix`: dock icons no longer flash letter tiles after a reload — live resolutions are cached to `~/.config/qsc/icon-cache.json` and served instantly while lookups warm up.

- `feat`: settings, notifications, popups and bar widgets follow the light/dark mode — new `GtkTheme.contentText/TextDim/pageBg/panelBg/cardBg/controlBg` tokens replace the static dark palette and hardcoded hex (incl. shared `ds/text`, `TextField` and `ListItem` defaults).

- `fix`: removed the fullscreen frame overlay (`shell/Border.qml`) — no more dark border around the screen edges.

- `fix`: startup no longer forces dark apps — theme enforce waits for `settings.json` to load, so the saved mode (e.g. light) wins.

- `fix`: removed the dock drop-shadow layer that read as a second gray shell over light wallpapers — single pill now.

- `feat`: runtime theme switch in System Settings → Appearance (shell owns the theme now, nix-config only installs theme files) — System/Light/Dark flips the shell instantly, rewrites the GTK theme + dconf so apps follow, and re-applies on every start; preference persists in `settings.json`.

- `feat`: real Apple SF Pro via `apple-fonts.nix` flake input — `sf-pro` in system fonts, first in fontconfig `sansSerif`, shell `sans` token now `"SF Pro Text"` (Inter stays as fallback).

- `feat`: Inter as the UI font — added to system `fonts.packages` + first in fontconfig `sansSerif` (`~/nix-config`), shell `sans` token now `"Inter"` (SF Pro's closest free look-alike); needs a system rebuild + switch.

- `feat`: menu bar goes fully bare like macOS — no fill, no blur, no shading, no edges; only text/icons over the wallpaper. Removed the now-dead `GtkTheme.barBg`/`barHairline`.

- `feat`: bar paints no solid fill anymore (macOS-like) — only compositor blur plus the shading gradient and faint top edge; removed the now-dead `GtkTheme.barBg`.

- `feat`: dock/bar closer to the macOS reference — dock body 0.15→0.45 so the pill reads over dark wallpapers, shorter/fainter separator, no bottom hairline on the dark bar, subtler top edge.

- `feat`: Niri blur softened via `~/nix-config` (`blur { passes 2; offset 2.0 }`, user-approved exception to the shell-only scope) — less frost on bar/dock glass plus cheaper GPU; needs a home-manager switch, Niri reloads its config live.

- `feat`: bar follows the GTK light/dark mode like the dock — bar glass, text, icons and hairline plus the menu-bar dropdowns switch palettes live (dark: graphite glass + white text); popups/notifications stay dark glass.

- `fix`: icon theme follows the system again (`WhiteSur-dark` pragma after the MacTahoe→WhiteSur switch broke every lookup into magenta checkers) + `hasThemeIcon` gating everywhere so a miss always falls back cleanly instead of rendering broken images.

- `feat`: liquid glass for menus — bar dropdowns (`MenuWindow` own blur + thinned light tint), notification center and bar popovers (thinned dark tint 0.62, subtle glass edge, blur regions that collapse to zero-area while hidden); launcher/settings stay opaque.

- `fix`: dock pill tint settled at 0.15 (0 was black over dark backdrops, 0.3 was milky) plus a real `onEntered` hover bug — Qt's `entered` signal carries no mouse event, so `mouse.x` threw on every cell entry.

- `feat`: real compositor blur behind bar + dock — `BackgroundEffect.blurRegion` (ext-background-effect, Niri 26.04+) covers the bar strip and dock pill (radius-matched); bar/dock tints thinned for the blur era; Niri's automatic xray keeps it cheap (wallpaper blur computed once).
- `fix`: shorter dock pill (74→68px) hugging 52px icons with symmetric 8px margins; wrapper/exclusion zone follows.
- `fix`: dock pill tint floored at zero in light mode (0.05 dark) plus softer edge whites — the pill is now pure blur + border + highlight + shadow; any remaining milk is Niri's blur recipe (strength/saturation), not shell tint.

- `feat`: dock follows the system GTK theme's light/dark mode — new `GtkTheme` service watches `gtk-3.0`/`gtk-4.0` `settings.ini` (theme name + prefer-dark) and the pill, tooltip, context menu, separator, running dot and fallback glyphs switch between graphite glass and light glass live.

- `fix`: pinned dock apps resolve via heuristic lookup — exact-id-only matching missed entries (e.g. pinned Discord showed a letter tile while running showed the real icon).
- `fix`: dock icons with no theme match no longer render a broken/missing texture — icon lookup probes with `iconPath(name, true)` plus a lowercase fallback and absolute-path support, falling back to the letter tile when unresolvable.
- `fix`: dock magnification now shrinks smoothly — icon sizes animate via `Behavior` and hover-clear is delayed (120ms) so moving between icons doesn't flicker and leaving the dock eases down instead of snapping.

- `feat`: system icon theme throughout the shell — `//@ pragma IconTheme MacTahoe-dark` so dock/launcher/tray app icons resolve from the theme; new `ThemeIcon` component renders theme glyphs tinted to shell colors with bundled-SVG fallback; bar status icons (volume, mic, network, VPN, bluetooth, battery, spotlight, bell, moon) and dock settings/trash now come from the theme.

- `fix`: input-mask Subtract regions restored so dock/settings/popouts/launcher receive clicks after the menu-window split.
- `fix`: menu-bar dropdowns are clickable now — the dropdown is its own layer window (`shell/MenuWindow.qml`, no mask, no overflow) instead of an overflowing child of the 28px bar, which Qt never hit-tests. (Earlier attempts via input-mask regions failed: `Subtract` can never add clickable areas and dynamic mask updates proved unreliable.)
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
