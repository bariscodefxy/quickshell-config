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
            onPinnedChanged: {
                if (root.pinned !== pinned)
                    root.pinned = pinned ?? ["thunar", "chromium-browser", "code", "Alacritty"];
            }
        }
    }
}
