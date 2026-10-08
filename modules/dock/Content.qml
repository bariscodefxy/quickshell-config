pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import qs.ds.icons
import qs.ds.text as DsText
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick

Item {
    id: root

    required property var panels
    required property ShellScreen screen
    required property PersistentProperties visibilities
    required property var wrapper

    readonly property int cellW: 58
    readonly property int iconSize: 52
    readonly property int pillH: 68
    // Snug macOS-like fill: 8px top and bottom, running dot tucks just
    // underneath the icon.
    readonly property int iconBottomMargin: 8

    property string menuKey: ""
    property real menuX: 0
    property int hoverIndex: -1
    property real hoverX: 0
    property bool hovering: false

    // Exposed for the compositor blur region so it matches the painted pill
    // exactly (the wrapper is a few px taller, which showed as a halo).
    property alias pillItem: pill

    function closeMenu(): void {
        root.menuKey = "";
        menuCloseTimer.stop();
    }

    function pretty(appId: string): string {
        if (!appId)
            return "?";
        let s = appId.split(".").pop().replace(/[-_]+/g, " ").trim();
        if (!s)
            return "?";
        return s.charAt(0).toUpperCase() + s.slice(1);
    }

    function lookup(appId: string): var {
        if (!appId)
            return null;
        if (typeof DesktopEntries.heuristicLookup === "function") {
            const e = DesktopEntries.heuristicLookup(appId);
            if (e)
                return e;
        }
        return root.entryById[appId] ?? root.entryById[appId.toLowerCase()] ?? null;
    }

    // Resolve an app icon to a loadable image URL, or "" when unresolvable.
    // Probing goes through hasThemeIcon: iconPath(name, true) proved
    // unreliable (missing theme returned a broken non-empty path = magenta
    // checkers), so never trust a path without a positive existence check.
    // Gated system-icon lookup shared by the settings/trash tiles:
    // never trust an unchecked iconPath (broken path = magenta checkers).
    function sysIcon(name: string): string {
        if (!name || typeof Quickshell.iconPath !== "function" || typeof Quickshell.hasThemeIcon !== "function")
            return "";
        if (!Quickshell.hasThemeIcon(name))
            return "";
        return Quickshell.iconPath(name);
    }

    // Dock icon with a persistent fallback: live resolution first,
    // last-known cached URL while DesktopEntries is still warming up
    // after a reload (otherwise running apps flash letter tiles).
    // NOTE: the store lives in onLiveSrcChanged, NOT in the appSrc
    // binding — writing the cache inside the binding that reads it is a
    // binding loop (the engine flags it and re-evaluates pointlessly).
    function appIconLive(item: var): string {
        if (!item || item.kind !== "app")
            return "";
        return root.appIconSrc(item.entry);
    }

    function appIconSrc(entry: var): string {
        if (!entry || !entry.icon)
            return "";
        const name = String(entry.icon);
        if (name.startsWith("/"))
            return "file://" + name;
        if (name.startsWith("file://") || name.startsWith("image://"))
            return name;
        if (typeof Quickshell.iconPath !== "function" || typeof Quickshell.hasThemeIcon !== "function")
            return "";
        if (Quickshell.hasThemeIcon(name))
            return Quickshell.iconPath(name);
        const lower = name.toLowerCase();
        if (lower !== name && Quickshell.hasThemeIcon(lower))
            return Quickshell.iconPath(lower);
        return "";
    }

    function launchEntry(entry: var): void {
        if (!entry)
            return;
        if (entry.runInTerminal)
            Niri.spawn(`alacritty -e ${entry.command.join(" ")}`);
        else
            Niri.spawn(entry.command.join(" "));
    }

    function activate(item: var): void {
        if (item.kind === "settings") {
            root.visibilities.settings = true;
            return;
        }
        if (item.kind === "trash") {
            Quickshell.execDetached(["sh", "-c", "thunar trash:///"]);
            return;
        }
        if (item.count > 0) {
            Niri.getWindowByAppId(item.appId, w => {
                if (w)
                    Niri.focusWindowById(w.id);
                else
                    root.launchEntry(item.entry);
            });
        } else {
            root.launchEntry(item.entry);
        }
    }

    function togglePin(item: var): void {
        const id = item.entry?.id ?? item.appId;
        if (!id)
            return;
        const pinned = [...Settings.pinned];
        const idx = pinned.findIndex(p => String(p).toLowerCase() === String(id).toLowerCase());
        if (idx >= 0)
            pinned.splice(idx, 1);
        else
            pinned.push(id);
        Settings.pinned = pinned;
    }

    readonly property var entryById: {
        const m = {};
        for (const a of DesktopEntries.applications.values) {
            m[a.id] = a;
            m[a.id.toLowerCase()] = a;
        }
        return m;
    }

    readonly property var running: {
        const groups = new Map();
        for (const t of ToplevelManager.toplevels.values) {
            const appId = t.appId || "";
            if (!appId)
                continue;
            const key = appId.toLowerCase();
            if (!groups.has(key)) {
                const entry = root.lookup(appId);
                groups.set(key, {
                    key: key,
                    appId: appId,
                    entry: entry,
                    name: entry?.name ?? root.pretty(appId),
                    count: 0
                });
            }
            groups.get(key).count++;
        }
        return [...groups.values()];
    }

    readonly property var items: {
        const list = [];
        const seen = new Set();
        for (const pid of Settings.pinned) {
            // Heuristic lookup (not exact map only): pinned ids like
            // "discord" don't always equal the desktop entry id, and an
            // exact-only miss showed a letter tile instead of the icon.
            const entry = root.lookup(String(pid));
            const run = root.running.find(r => (r.entry && entry && r.entry.id === entry.id) || r.key === String(pid).toLowerCase());
            if (!entry && !run)
                continue;
            const key = entry ? String(entry.id).toLowerCase() : run.key;
            seen.add(key);
            list.push({
                kind: "app",
                key: key,
                appId: run?.appId ?? String(pid),
                entry: entry ?? run?.entry ?? null,
                name: entry?.name ?? run?.name ?? root.pretty(String(pid)),
                count: run?.count ?? 0,
                pinned: true
            });
        }
        for (const r of root.running) {
            if (seen.has(r.key))
                continue;
            list.push({
                kind: "app",
                key: r.key,
                appId: r.appId,
                entry: r.entry,
                name: r.name,
                count: r.count,
                pinned: false
            });
        }
        list.push({
            kind: "settings",
            key: "settings",
            name: "System Settings",
            count: 0
        });
        list.push({ kind: "sep", key: "sep", name: "", count: 0 });
        list.push({
            kind: "trash",
            key: "trash",
            name: "Trash",
            count: 0
        });
        return list;
    }

    readonly property var menuRows: {
        if (root.menuKey === "")
            return [];
        const item = root.items.find(i => i.key === root.menuKey);
        if (!item || item.kind !== "app")
            return [];
        const rows = [];
        rows.push({
            label: item.count > 0 ? "Focus" : "Open",
            action: () => root.activate(item)
        });
        if (item.count > 0) {
            rows.push({
                label: "Quit",
                action: () => Niri.closeAppWindows(item.appId)
            });
        }
        rows.push({ separator: true });
        rows.push({
            label: item.pinned ? "Remove from Dock" : "Keep in Dock",
            action: () => root.togglePin(item)
        });
        return rows;
    }

    // Slot centers stay on the fixed grid (index-based) so magnification
    // never feeds back into itself; only the slot WIDTHS stretch with
    // growth, giving neighbors room instead of overlapping.
    function mag(index: int): real {
        if (!root.hovering)
            return 1;
        const center = (index + 0.5) * root.cellW;
        const d = Math.abs(center - root.hoverX) / (2.2 * root.cellW);
        return 1 + 0.55 * Math.max(0, 1 - d);
    }

    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    implicitHeight: root.pillH + 4
    implicitWidth: pill.width

    Timer {
        id: menuCloseTimer

        interval: 250
        repeat: false

        onTriggered: {
            root.closeMenu();
        }
    }

    // Delayed hover-clear: keeps `hovering` true while moving between cells
    // so magnification doesn't flicker, and lets the icon shrink animate
    // smoothly after the mouse truly leaves the dock.
    Timer {
        id: hoverClearTimer

        interval: 120
        repeat: false

        onTriggered: {
            root.hovering = false;
            root.hoverIndex = -1;
        }
    }

    // Tooltip
    Rectangle {
        anchors.bottom: pill.top
        anchors.bottomMargin: 8
        color: GtkTheme.tooltipBg
        height: tipText.implicitHeight + 10
        radius: 6
        visible: root.hovering && root.hoverIndex >= 0 && root.menuKey === ""
        width: tipText.implicitWidth + 20
        x: Math.max(0, Math.min(pill.width - width, row.x + root.hoverX - width / 2))
        z: 50

        border.color: GtkTheme.hairline
        border.width: 1

        DsText.BodyS {
            id: tipText

            anchors.centerIn: parent
            color: GtkTheme.surfaceText
            font.family: Foundations.font.family.sans
            text: root.hoverIndex >= 0 && root.items[root.hoverIndex] ? root.items[root.hoverIndex].name : ""
        }
    }

    // Context menu
    Rectangle {
        id: menu

        color: GtkTheme.menuBg
        height: menuCol.implicitHeight + 12
        radius: 10
        visible: root.menuKey !== ""
        width: 210
        x: Math.max(8, Math.min(pill.width - width - 8, root.menuX - width / 2))
        y: -height - 10
        z: 60

        border.color: GtkTheme.hairline
        border.width: 1

        Column {
            id: menuCol

            anchors.centerIn: parent
            width: parent.width - 12

            Repeater {
                model: root.menuRows

                delegate: Item {
                    id: mrow

                    required property int index
                    required property var modelData

                    height: modelData.separator ? 9 : 26
                    width: menuCol.width

                    Rectangle {
                        anchors.centerIn: parent
                        color: GtkTheme.menuSeparator
                        height: 1
                        visible: modelData.separator
                        width: parent.width - 8
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: mrowMouse.containsMouse ? "#0a84ff" : "transparent"
                        radius: 6
                        visible: !modelData.separator
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        color: mrowMouse.containsMouse ? "#ffffff" : GtkTheme.surfaceText
                        font.family: Foundations.font.family.sans
                        font.pointSize: 10
                        text: modelData.label ?? ""
                        visible: !modelData.separator
                    }

                    MouseArea {
                        id: mrowMouse

                        anchors.fill: parent
                        enabled: !modelData.separator
                        hoverEnabled: true

                        onClicked: {
                            const act = modelData.action;
                            root.closeMenu();
                            if (act)
                                act();
                        }
                        onEntered: menuCloseTimer.stop()
                        onExited: menuCloseTimer.start()
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            propagateComposedEvents: false
            z: -1

            onEntered: menuCloseTimer.stop()
            onExited: menuCloseTimer.start()
        }
    }

    // Pill
    Rectangle {
        id: pill

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: GtkTheme.dockBg
        height: root.pillH
        width: row.width + 20

        // The pill breathes with magnification instead of snapping.
        Behavior on width {
            NumberAnimation {
                duration: Foundations.duration.fast
                easing.type: Easing.OutCubic
            }
        }

        border.color: GtkTheme.dockBorder
        border.width: 1
        radius: 22

        // Full-perimeter inner glass edge: defines the rounded corners
        // against the blurred backdrop, macOS-style.
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            border.color: GtkTheme.edgeLight
            border.width: 1
            color: "transparent"
            radius: 21
        }

        // Top specular highlight, inset to stay clear of the corner curves.
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 1
            color: GtkTheme.topHighlight
            height: 1
            radius: 1
            width: parent.width - 48
        }

        Row {
            id: row

            anchors.centerIn: parent
            height: parent.height

            Repeater {
                model: root.items

                delegate: Item {
                    id: cell

                    required property int index
                    required property var modelData

                    readonly property real m: root.mag(cell.index)
                    readonly property real iconH: root.iconSize * cell.m

                    height: row.height
                    // The slot stretches exactly by the icon's growth, so a
                    // magnified icon always fits its cell (3px clearance per
                    // side) and pushes neighbors aside instead of overlapping.
                    width: root.cellW + (cell.iconH - root.iconSize)

                    Behavior on width {
                        NumberAnimation {
                            duration: Foundations.duration.fast
                            easing.type: Easing.OutCubic
                        }
                    }

                    // App icon
                    Item {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: root.iconBottomMargin
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: cell.iconH
                        width: cell.iconH

                        // Smooth grow + shrink instead of snapping.
                        Behavior on height {
                            NumberAnimation {
                                duration: Foundations.duration.fast
                                easing.type: Easing.OutCubic
                            }
                        }
                        Behavior on width {
                            NumberAnimation {
                                duration: Foundations.duration.fast
                                easing.type: Easing.OutCubic
                            }
                        }

                        readonly property string themeSrc: root.sysIcon(cell.modelData.kind === "settings" ? "preferences-system" : cell.modelData.kind === "trash" ? "user-trash" : "")
                        readonly property string liveSrc: root.appIconLive(cell.modelData)
                        readonly property string appSrc: liveSrc !== "" ? liveSrc : DockIconCache.lookup(cell.modelData.key)

                        onLiveSrcChanged: {
                            if (liveSrc !== "")
                                DockIconCache.store(cell.modelData.key, cell.modelData.name, liveSrc);
                        }

                        IconImage {
                            anchors.fill: parent
                            source: parent.appSrc
                            visible: parent.appSrc !== ""
                        }

                        IconImage {
                            anchors.fill: parent
                            source: parent.themeSrc
                            visible: parent.themeSrc !== ""
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: "#48484e"
                            radius: 10
                            visible: cell.modelData.kind === "app" && parent.appSrc === ""
                        }

                        Text {
                            anchors.centerIn: parent
                            color: "#ffffff"
                            font.family: Foundations.font.family.sans
                            font.pointSize: 18
                            font.weight: Font.Bold
                            text: (cell.modelData.name || "?").charAt(0)
                            visible: cell.modelData.kind === "app" && parent.appSrc === ""
                        }

                        MacIcon {
                            anchors.centerIn: parent
                            color: GtkTheme.surfaceText
                            name: cell.modelData.kind === "settings" ? "gear" : "trash"
                            size: Math.min(30, cell.iconH * 0.62)
                            visible: cell.modelData.kind !== "app" && cell.modelData.kind !== "sep" && parent.themeSrc === ""
                        }
                    }

                    // Separator: short and faint like the reference pill.
                    Rectangle {
                        anchors.centerIn: parent
                        color: GtkTheme.dockSep
                        height: 40
                        visible: cell.modelData.kind === "sep"
                        width: 1
                    }

                    // Running dot
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 3
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: GtkTheme.dot
                        height: 4
                        radius: 2
                        visible: cell.modelData.count > 0
                        width: 4
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true

                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton) {
                                if (cell.modelData.kind === "app") {
                                    menuCloseTimer.stop();
                                    root.menuKey = cell.modelData.key;
                                    root.menuX = row.x + (cell.index + 0.5) * root.cellW;
                                }
                            } else {
                                root.closeMenu();
                                root.activate(cell.modelData);
                            }
                        }
                        onEntered: {
                            hoverClearTimer.stop();
                            root.hoverX = (cell.index + 0.5) * root.cellW;
                            root.hovering = true;
                            root.hoverIndex = cell.index;
                        }
                        onExited: {
                            if (root.hoverIndex === cell.index)
                                root.hoverIndex = -1;
                            hoverClearTimer.restart();
                        }
                        onPositionChanged: mouse => {
                            hoverClearTimer.stop();
                            // Map the pointer back onto the fixed grid: slots
                            // stretch as icons grow, but mag() reads grid
                            // coords. Normalized per-cell so slot edges agree
                            // (no jumps when crossing). Handler context, so
                            // no binding loop.
                            root.hoverX = cell.index * root.cellW + mouse.x * (root.cellW / cell.width);
                            root.hovering = true;
                            root.hoverIndex = cell.index;
                        }
                    }
                }
            }
        }
    }
}
