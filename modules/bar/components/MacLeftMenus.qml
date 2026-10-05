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
    // Bar root: window coordinates for the input-mask measurement.
    required property Item windowRef

    signal closeRequested()
    signal openRequested(string name)

    // Open menu geometry in window coordinates, for the shell input mask.
    // Measured imperatively after layout settles: binding chains through
    // mapToItem collapsed to zero and clicks fell through to the app below.
    property rect menuGeo: Qt.rect(0, 0, 0, 0)
    property string pendingMenu: ""
    property int measureTries: 0

    onOpenMenuChanged: {
        root.menuGeo = Qt.rect(0, 0, 0, 0);
        measureTimer.stop();
        if (root.openMenu !== "") {
            root.pendingMenu = root.openMenu;
            root.measureTries = 0;
            measureTimer.start();
        }
    }

    onActiveAppIdChanged: {
        // Menu items rebuild per app; re-measure if a menu is open.
        if (root.openMenu !== "") {
            root.pendingMenu = root.openMenu;
            root.measureTries = 0;
            measureTimer.stop();
            measureTimer.start();
        }
    }

    Timer {
        id: measureTimer

        interval: 50
        repeat: false

        onTriggered: root.measureMenu()
    }

    function measureMenu(): void {
        for (let i = 0; i < children.length; i++) {
            const c = children[i];
            if (c && c.menuName === root.pendingMenu && c.dropdownItem !== undefined) {
                const h = c.dropdownItem.height;
                if (h <= 0 && root.measureTries < 5) {
                    root.measureTries++;
                    measureTimer.start();
                    return;
                }
                const p = c.mapToItem(root.windowRef, 0, c.height + 4);
                root.menuGeo = Qt.rect(p.x - 4, p.y - 2, c.dropdownWidth + 8, h + 12);
                return;
            }
        }
        root.menuGeo = Qt.rect(0, 0, 0, 0);
    }

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

    function quitActiveApp(): void {
        if (root.activeAppId)
            Niri.closeAppWindows(root.activeAppId);
        else
            Niri.closeFocusedWindow();
    }

    function runItem(d: var): void {
        if (!d)
            return;
        if (d.kind === "shell")
            root.shellOut(d.arg);
        else if (d.kind === "spawn")
            Niri.spawn(d.arg);
        else if (d.kind === "dir")
            root.openDir(d.arg ?? "");
        else if (d.kind === "launcher")
            root.openLauncher(d.arg ?? "");
        else if (d.kind === "settings")
            root.visibilities.settings = true;
        else if (d.kind === "quitapp")
            root.quitActiveApp();
        else if (d.kind === "niri")
            root.runNiriAction(d.arg);
    }

    function runNiriAction(name: string): void {
        if (name === "closeFocusedWindow")
            Niri.closeFocusedWindow();
        else if (name === "toggleOverview")
            Niri.toggleOverview();
        else if (name === "openOverview")
            Niri.openOverview();
        else if (name === "toggleFullscreen")
            Niri.toggleFullscreen();
        else if (name === "maximizeColumn")
            Niri.maximizeColumn();
        else if (name === "toggleFloating")
            Niri.toggleFloating();
        else if (name === "focusNextWindow")
            Niri.focusNextWindow();
        else if (name === "focusPrevWindow")
            Niri.focusPrevWindow();
        else if (name === "showHotkeyOverlay")
            Niri.showHotkeyOverlay();
    }

    function withActions(descriptors: var): var {
        return descriptors.map(d => {
            if (d.separator === true)
                return { separator: true };
            return { label: d.label, shortcut: d.shortcut, action: () => root.runItem(d) };
        });
    }

    function fileMenuItems(): var {
        return root.withActions(AppMenus.fileItems(root.activeAppId));
    }

    function goMenuItems(): var {
        return root.withActions(AppMenus.goItems(root.activeAppId));
    }

    onActiveToplevelChanged: {
        // Clicking into an app window passes through the clickthrough mask,
        // so dismiss open menus on focus change (macOS behavior).
        if (root.openMenu !== "")
            root.closeRequested();
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
            { label: `Quit ${root.appName}`, shortcut: "⌘Q", action: () => root.quitActiveApp() }
        ]

        onCloseRequested: root.closeRequested()
        onOpenRequested: name => root.openRequested(name)
    }

    MacMenu {
        menuName: "file"
        titleText: "File"
        openMenu: root.openMenu
        dropdownWidth: 250
        items: root.fileMenuItems()

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
        items: root.goMenuItems()

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
