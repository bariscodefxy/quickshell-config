pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.ds
import qs.services

// Tracks the system GTK theme's light/dark mode and exposes dock surfaces
// that follow it. Compiled themes (e.g. WhiteSur's gresource) expose no
// parseable color, so we follow the mode (theme name + prefer-dark flag
// from settings.ini), not a hex value. Unknown/missing config keeps the
// current dark glass.
Singleton {
    id: root

    readonly property string configHome: {
        const xdg = Quickshell.env("XDG_CONFIG_HOME");
        if (xdg)
            return String(xdg);
        return `${Quickshell.env("HOME")}/.config`;
    }
    readonly property string gtk3Path: `${root.configHome}/gtk-3.0/settings.ini`
    readonly property string gtk4Path: `${root.configHome}/gtk-4.0/settings.ini`

    property string themeName: ""
    property bool preferDark: false

    readonly property bool hasData: gtk3.loaded || gtk4.loaded
    readonly property bool isDark: !root.hasData ? true : (root.preferDark || root.themeName === "" || root.themeName.toLowerCase().indexOf("dark") !== -1)

    // Bar (menu-bar) surfaces. The bar itself paints nothing (macOS-like):
    // only menu text/icons over the wallpaper. Text/icons follow the mode.
    readonly property color barText: root.isDark ? "#f5f5f7" : Foundations.glass.barText
    readonly property color barIcon: root.isDark ? "#f5f5f7" : Foundations.glass.barIcon
    // Pill
    // macOS-like translucency: the pill is mostly blurred backdrop with a
    // whisper of tint. Niri boosts blurred-background saturation (1.5x), so
    // icons pop like the reference dock. Tint stays slightly present so the
    // pill never goes fully black over dark backdrops.
    readonly property color dockBg: root.isDark ? Qt.alpha("#1e1e28", 0.45) : Qt.alpha(Foundations.glass.barBg, 0.15)
    readonly property color dockBorder: root.isDark ? Qt.alpha("#ffffff", 0.2) : Qt.alpha("#000000", 0.2)
    readonly property color edgeLight: root.isDark ? Qt.alpha("#ffffff", 0.22) : Qt.alpha("#ffffff", 0.35)
    readonly property color topHighlight: root.isDark ? Qt.alpha("#ffffff", 0.3) : Qt.alpha("#ffffff", 0.3)
    readonly property color dockSep: root.isDark ? Qt.alpha("#ffffff", 0.12) : Qt.alpha("#000000", 0.12)
    readonly property color dot: root.isDark ? "#ffffff" : Foundations.glass.barIcon

    // Tooltip + context menu (no blur behind these, so they keep enough
    // body to stay readable over sharp backdrops).
    readonly property color tooltipBg: root.isDark ? Qt.alpha("#1e1e28", 0.65) : Qt.alpha(Foundations.glass.menuBg, 0.62)
    readonly property color menuBg: root.isDark ? Qt.alpha("#232329", 0.7) : Qt.alpha(Foundations.glass.menuBg, 0.68)
    readonly property color surfaceText: root.isDark ? "#f5f5f7" : Foundations.glass.menuText
    readonly property color hairline: root.isDark ? Qt.alpha("#ffffff", 0.12) : Foundations.glass.menuSeparator
    readonly property color menuSeparator: root.isDark ? Qt.alpha("#ffffff", 0.1) : Qt.alpha("#000000", 0.1)

    function readKey(text: string, key: string): string {
        for (const line of text.split("\n")) {
            const t = line.trim();
            if (t.startsWith(key)) {
                const i = t.indexOf("=");
                if (i !== -1)
                    return t.slice(i + 1).trim();
            }
        }
        return "";
    }

    function refresh(): void {
        const t3 = gtk3.loaded ? gtk3.text() : "";
        const t4 = gtk4.loaded ? gtk4.text() : "";
        const name = root.readKey(t3, "gtk-theme-name") || root.readKey(t4, "gtk-theme-name");
        if (name !== "")
            root.themeName = name;
        root.preferDark = root.readKey(t3, "gtk-application-prefer-dark-theme") === "true" || root.readKey(t4, "gtk-application-prefer-dark-theme") === "true";
    }

    FileView {
        id: gtk3

        path: root.gtk3Path
        watchChanges: true

        onFileChanged: gtk3.reload()
        onLoaded: root.refresh()
    }

    FileView {
        id: gtk4

        path: root.gtk4Path
        watchChanges: true

        onFileChanged: gtk4.reload()
        onLoaded: root.refresh()
    }
}
