pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    required property string openMenu
    required property var screen
    required property PersistentProperties visibilities

    signal closeRequested()
    signal openRequested(string name)

    property Toplevel activeToplevel: ToplevelManager.activeToplevel
    property string activeAppId: ""
    property string activeTitle: ""

    readonly property string appName: prettyName(root.activeAppId)

    spacing: 2

    function prettyName(appId: string): string {
        if (!appId)
            return "Finder";
        let s = appId.split(".").pop().replace(/[-_]+/g, " ").trim();
        if (!s)
            return "Finder";
        return s.charAt(0).toUpperCase() + s.slice(1);
    }

    function shellOut(cmd: string): void {
        Quickshell.execDetached(["sh", "-c", cmd]);
    }

    function notifyAbout(title: string, body: string): void {
        const t = title.replace(/'/g, "").slice(0, 60);
        const b = body.replace(/'/g, "").slice(0, 160);
        Quickshell.execDetached(["sh", "-c", `notify-send '${t}' '${b}'`]);
    }

    function openDir(path: string): void {
        if (path === "")
            Quickshell.execDetached(["sh", "-c", "thunar ~"]);
        else
            Quickshell.execDetached(["sh", "-c", `mkdir -p ~/"${path}" && thunar ~/"${path}"`]);
    }

    function openLauncher(text: string): void {
        root.visibilities.launcher = true;
        root.visibilities.searchText = text;
    }

    Component.onCompleted: {
        activeToplevel = Qt.binding(() => {
            const trigger = ToplevelManager.activeToplevel;
            const toplevels = ToplevelManager.toplevels.values;

            if (!toplevels || !toplevels.length)
                return activeToplevel;

            for (let i = 0; i < toplevels.length; i++) {
                const toplevel = toplevels[i];
                if (toplevel && toplevel.activated) {
                    if (toplevel.screens && toplevel.screens.length > 0) {
                        const toplevelScreen = toplevel.screens[0];
                        if (screen.name === toplevelScreen.name)
                            return toplevel;
                    }
                }
            }

            return activeToplevel;
        });

        activeTitle = Qt.binding(() => activeToplevel?.title ?? "");
        activeAppId = Qt.binding(() => activeToplevel?.appId ?? "");
    }

    MacMenu {
        menuName: "apple"
        titleText: ""
        titleIcon: "apple"
        titleIconSize: 15
        openMenu: root.openMenu
        dropdownWidth: 240
        items: [
            { label: "System Settings…", action: () => root.visibilities.settings = true },
            { separator: true },
            { label: "About This Mac", action: () => Niri.spawn("alacritty -e fastfetch") },
            { separator: true },
            { label: "Lock Screen", action: () => root.shellOut("swaylock") },
            { label: "Sleep", action: () => root.shellOut("systemctl suspend") },
            { separator: true },
            { label: "Restart…", action: () => root.shellOut("systemctl reboot") },
            { label: "Shut Down…", action: () => root.shellOut("systemctl poweroff") },
            { label: "Log Out…", shortcut: "⇧⌘Q", action: () => Niri.quitCompositor() }
        ]

        onCloseRequested: root.closeRequested()
        onOpenRequested: name => root.openRequested(name)
    }

    MacMenu {
        menuName: "app"
        titleText: root.appName
        titleBold: true
        openMenu: root.openMenu
        dropdownWidth: 250
        items: [
            { label: `About ${root.appName}`, action: () => root.notifyAbout(`About ${root.appName}`, `${root.activeAppId || "Desktop"}\n${root.activeTitle || "No focused window"}`) },
            { separator: true },
            { label: `Quit ${root.appName}`, shortcut: "⌘Q", action: () => Niri.closeFocusedWindow() }
        ]

        onCloseRequested: root.closeRequested()
        onOpenRequested: name => root.openRequested(name)
    }

    MacMenu {
        menuName: "file"
        titleText: "File"
        openMenu: root.openMenu
        dropdownWidth: 250
        items: [
            { label: "New Finder Window", shortcut: "⌘N", action: () => root.shellOut("thunar ~") },
            { label: "New Folder", shortcut: "⇧⌘N", action: () => root.shellOut("mkdir -p ~/'Untitled Folder' && thunar ~") },
            { label: "Open…", shortcut: "⌘O", action: () => root.shellOut("thunar ~") },
            { separator: true },
            { label: "Close Window", shortcut: "⌘W", action: () => Niri.closeFocusedWindow() }
        ]

        onCloseRequested: root.closeRequested()
        onOpenRequested: name => root.openRequested(name)
    }

    MacMenu {
        menuName: "edit"
        titleText: "Edit"
        openMenu: root.openMenu
        dropdownWidth: 250
        items: [
            { label: "Show Clipboard", action: () => root.openLauncher("!") },
            { label: "Clear Clipboard", action: () => root.shellOut("wl-copy --clear") },
            { separator: true },
            { label: "Take Screenshot", action: () => root.shellOut("niri msg action screenshot") }
        ]

        onCloseRequested: root.closeRequested()
        onOpenRequested: name => root.openRequested(name)
    }

    MacMenu {
        menuName: "view"
        titleText: "View"
        openMenu: root.openMenu
        dropdownWidth: 250
        items: [
            { label: "Toggle Overview", action: () => Niri.toggleOverview() },
            { label: "Full Screen", shortcut: "⌃⌘F", action: () => Niri.toggleFullscreen() },
            { label: "Maximize Column", action: () => Niri.maximizeColumn() },
            { label: "Toggle Floating", action: () => Niri.toggleFloating() }
        ]

        onCloseRequested: root.closeRequested()
        onOpenRequested: name => root.openRequested(name)
    }

    MacMenu {
        menuName: "go"
        titleText: "Go"
        openMenu: root.openMenu
        dropdownWidth: 220
        items: [
            { label: "Home", shortcut: "⇧⌘H", action: () => root.openDir("") },
            { label: "Documents", action: () => root.openDir("Documents") },
            { label: "Downloads", action: () => root.openDir("Downloads") },
            { label: "Music", action: () => root.openDir("Music") },
            { label: "Pictures", action: () => root.openDir("Pictures") }
        ]

        onCloseRequested: root.closeRequested()
        onOpenRequested: name => root.openRequested(name)
    }

    MacMenu {
        menuName: "window"
        titleText: "Window"
        openMenu: root.openMenu
        dropdownWidth: 250
        items: [
            { label: "Next Window", shortcut: "⌘`", action: () => Niri.focusNextWindow() },
            { label: "Previous Window", shortcut: "⇧⌘`", action: () => Niri.focusPrevWindow() },
            { separator: true },
            { label: "Show All Windows", action: () => Niri.openOverview() },
            { separator: true },
            { label: "Close Window", action: () => Niri.closeFocusedWindow() }
        ]

        onCloseRequested: root.closeRequested()
        onOpenRequested: name => root.openRequested(name)
    }

    MacMenu {
        menuName: "help"
        titleText: "Help"
        openMenu: root.openMenu
        dropdownWidth: 250
        items: [
            { label: "Search…", shortcut: "⇧⌘/", action: () => root.openLauncher("") },
            { label: "Keyboard Shortcuts", action: () => Niri.showHotkeyOverlay() },
            { label: "Niri Wiki", action: () => root.shellOut("xdg-open https://github.com/YaLTeR/niri/wiki") }
        ]

        onCloseRequested: root.closeRequested()
        onOpenRequested: name => root.openRequested(name)
    }
}
