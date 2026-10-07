pragma ComponentBehavior: Bound

import qs.ds
import qs.services
import qs.modules.popups as BarPopouts
import Quickshell
import QtQuick
import qs.ds.animations

Item {
    id: root

    readonly property int contentHeight: barHeight
    readonly property int exclusiveZone: contentHeight
    property bool isHovered
    required property BarPopouts.Wrapper popouts
    required property ShellScreen screen
    readonly property bool shouldBeVisible: true
    required property PersistentProperties visibilities
    required property int margin
    required property int barHeight

    function closeMenus(): void {
        content.item?.closeMenus();
    }

    // Open menu state for the separate menu window (shell/MenuWindow.qml).
    // Read through the typed Bar reference (dynamic lookup on the
    // Item-typed Loader.item would not subscribe to updates).
    readonly property Bar barItem: content.item
    readonly property int menuX: barItem ? barItem.menuX : 0
    readonly property int menuY: barItem ? barItem.menuY : 0
    readonly property int menuW: barItem ? barItem.menuW : 250
    readonly property var menuItems: barItem ? barItem.menuItems : []
    readonly property bool menuOpen: barItem ? barItem.openMenu !== "" : false
    implicitHeight: root.contentHeight
    visible: true

    // Bare menu bar (macOS-like): no fill, no blur, no shading, no edges.
    // Only the menu content (text/icons) paints over the wallpaper.
    // Visuals stay 28px: the wrapper is taller (hit-test area for the
    // overflowing dropdowns) but nothing else is painted.

    Loader {
        id: content

        active: root.shouldBeVisible || root.visible
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.barHeight

        sourceComponent: Bar {
            height: root.barHeight
            innerHeight: root.barHeight
            popouts: root.popouts
            screen: root.screen
            visibilities: root.visibilities
            width: parent.width
        }
    }
}
