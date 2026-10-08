pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string filePath: `${Quickshell.env("HOME")}/.config/qsc/settings.json`

    property real glass: 0.55

    property bool showAudio: true
    property bool showNetwork: true
    property bool showVpn: true
    property bool showBluetooth: true
    property bool showBattery: true
    property bool showKbLayout: true
    property bool showTray: true
    property bool showSpotlight: true
    property bool showDate: true
    property bool clock24h: false

    property string wallpaper: ""
    property string wallpaperDir: "~/Pictures/Wallpapers"
    property string wallpaperMode: "fill"
    property var pinned: ["thunar", "chromium-browser", "code", "Alacritty"]

    // Runtime theme, edited from System Settings → Appearance. The shell
    // owns the theme: "light"/"dark" flip the shell instantly AND rewrite
    // the GTK files + dconf so apps follow. "system" just follows the
    // settings.ini files (for external tools). Nothing theme-related lives
    // in nix-config; it only installs the theme files, never selects.
    // The nix store symlinks are replaced by real files (originals backed
    // up under ~/.config/qsc/); a nix-config switch resets the files, and
    // the shell re-applies its theme on the next start.
    property string themeMode: "dark"

    function setThemeMode(mode: string): void {
        root.themeMode = mode;
        if (mode === "light" || mode === "dark")
            root.applyAppTheme(mode === "dark");
        else
            root.restoreAppTheme();
    }

    function applyAppTheme(dark: bool): void {
        const home = Quickshell.env("HOME") || "";
        const gtk = dark ? "WhiteSur-Dark" : "WhiteSur-Light";
        const icon = dark ? "WhiteSur-dark" : "WhiteSur-light";
        const pref = dark ? "true" : "false";
        const scheme = dark ? "prefer-dark" : "prefer-light";
        Quickshell.execDetached(["sh", "-c", `
            for v in 3.0 4.0; do
              f="${home}/.config/gtk-$v/settings.ini"
              b="${home}/.config/qsc/gtk-$v-settings.ini.bak"
              [ -e "$b" ] || cp -L "$f" "$b"
              tmp=$(mktemp)
              sed -e "s/^gtk-theme-name=.*/gtk-theme-name=${gtk}/" -e "s/^gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=${pref}/" -e "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=${icon}/" "$f" > "$tmp"
              rm -f "$f"; cp "$tmp" "$f"; rm -f "$tmp"
            done
            dconf write /org/gnome/desktop/interface/gtk-theme "'${gtk}'"
            dconf write /org/gnome/desktop/interface/color-scheme "'${scheme}'"
        `]);
    }

    function restoreAppTheme(): void {
        const home = Quickshell.env("HOME") || "";
        Quickshell.execDetached(["sh", "-c", `
            for v in 3.0 4.0; do
              f="${home}/.config/gtk-$v/settings.ini"
              b="${home}/.config/qsc/gtk-$v-settings.ini.bak"
              if [ -e "$b" ]; then rm -f "$f"; cp "$b" "$f"; fi
            done
            t=$(grep '^gtk-theme-name=' "${home}/.config/gtk-3.0/settings.ini" | cut -d= -f2)
            case "$t" in *ark*) s=prefer-dark;; *) s=prefer-light;; esac
            if [ -n "$t" ]; then
              dconf write /org/gnome/desktop/interface/gtk-theme "'$t'"
              dconf write /org/gnome/desktop/interface/color-scheme "'$s'"
            fi
        `]);
    }

    function glassBarOpacity(): real {
        // Real compositor blur is behind the bar now, so the base tint can
        // stay light and glassy. Slider still trims the last bit.
        return 0.35 + root.glass * 0.3;
    }

    function glassMenuOpacity(): real {
        return 0.68 + root.glass * 0.3;
    }

    function expandHome(path: string): string {
        if (path.startsWith("~/"))
            return (Quickshell.env("HOME") || "") + path.slice(1);
        return path;
    }

    function shellQuote(path: string): string {
        return "'" + path.replace(/'/g, "") + "'";
    }

    function ensureDaemonAnd(cmd: string): void {
        Quickshell.execDetached(["sh", "-c", `(pgrep -x awww-daemon >/dev/null || (awww-daemon >/dev/null 2>&1 & sleep 1)); ${cmd}`]);
    }

    function applyWallpaper(): void {
        if (root.wallpaper === "")
            return;
        const resize = root.wallpaperMode === "fit" ? "fit" : "crop";
        root.ensureDaemonAnd(`awww img ${root.shellQuote(root.wallpaper)} --resize ${resize} --transition-type fade --transition-duration 0.6`);
    }

    function setWallpaper(path: string): void {
        root.wallpaper = path;
        root.applyWallpaper();
    }

    function scheduleSave(): void {
        saveTimer.restart();
    }

    Component.onCompleted: {
        Quickshell.execDetached(["sh", "-c", "mkdir -p ~/.config/qsc"]);
        settingsFile.reload();
        restoreTimer.start();
        // The shell owns the theme: enforce it shortly after start (NOT
        // immediately — settings.json loads async, and enforcing with the
        // "dark" default first overwrote the user's saved mode on every
        // launch). By the time this fires, the adapter has synced.
        themeEnforceTimer.start();
    }

    // One-shot: re-applies the saved theme once per start so the
    // settings.ini files always carry our selection (a nix-config switch
    // resets them to keyless files). Never re-fires on later saves.
    Timer {
        id: themeEnforceTimer

        interval: 1500
        repeat: false

        onTriggered: {
            if (root.themeMode === "light" || root.themeMode === "dark")
                root.applyAppTheme(root.themeMode === "dark");
        }
    }

    Timer {
        id: restoreTimer

        interval: 2000
        repeat: false

        onTriggered: {
            root.applyWallpaper();
        }
    }

    onGlassChanged: root.scheduleSave()
    onShowAudioChanged: root.scheduleSave()
    onShowNetworkChanged: root.scheduleSave()
    onShowVpnChanged: root.scheduleSave()
    onShowBluetoothChanged: root.scheduleSave()
    onShowBatteryChanged: root.scheduleSave()
    onShowKbLayoutChanged: root.scheduleSave()
    onShowTrayChanged: root.scheduleSave()
    onShowSpotlightChanged: root.scheduleSave()
    onShowDateChanged: root.scheduleSave()
    onClock24hChanged: root.scheduleSave()
    onWallpaperChanged: root.scheduleSave()
    onWallpaperDirChanged: root.scheduleSave()
    onWallpaperModeChanged: root.scheduleSave()
    onPinnedChanged: root.scheduleSave()
    onThemeModeChanged: root.scheduleSave()

    Timer {
        id: saveTimer

        interval: 500
        repeat: false

        onTriggered: {
            settingsFile.writeAdapter();
        }
    }

    FileView {
        id: settingsFile

        path: root.filePath
        watchChanges: true

        JsonAdapter {
            property real glass: root.glass
            property bool showAudio: root.showAudio
            property bool showNetwork: root.showNetwork
            property bool showVpn: root.showVpn
            property bool showBluetooth: root.showBluetooth
            property bool showBattery: root.showBattery
            property bool showKbLayout: root.showKbLayout
            property bool showTray: root.showTray
            property bool showSpotlight: root.showSpotlight
            property bool showDate: root.showDate
            property bool clock24h: root.clock24h
            property string wallpaper: root.wallpaper
            property string wallpaperDir: root.wallpaperDir
            property string wallpaperMode: root.wallpaperMode
            property var pinned: root.pinned
            property string themeMode: root.themeMode

            onGlassChanged: root.glass = glass ?? 0.55
            onShowAudioChanged: root.showAudio = showAudio ?? true
            onShowNetworkChanged: root.showNetwork = showNetwork ?? true
            onShowVpnChanged: root.showVpn = showVpn ?? true
            onShowBluetoothChanged: root.showBluetooth = showBluetooth ?? true
            onShowBatteryChanged: root.showBattery = showBattery ?? true
            onShowKbLayoutChanged: root.showKbLayout = showKbLayout ?? true
            onShowTrayChanged: root.showTray = showTray ?? true
            onShowSpotlightChanged: root.showSpotlight = showSpotlight ?? true
            onShowDateChanged: root.showDate = showDate ?? true
            onClock24hChanged: root.clock24h = clock24h ?? false
            onWallpaperChanged: root.wallpaper = wallpaper ?? ""
            onWallpaperDirChanged: root.wallpaperDir = wallpaperDir ?? "~/Pictures/Wallpapers"
            onWallpaperModeChanged: root.wallpaperMode = wallpaperMode ?? "fill"
            onThemeModeChanged: root.themeMode = themeMode ?? "dark"
            onPinnedChanged: {
                if (root.pinned !== pinned)
                    root.pinned = pinned ?? ["thunar", "chromium-browser", "code", "Alacritty"];
            }
        }
    }
}
