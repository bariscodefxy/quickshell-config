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

    // Liquid glass bar: frosted base + top-down sheen + specular top edge.
    // (True background blur is unavailable — the compositor blur rule broke
    // app window rendering — so depth is faked with layered translucency.)
    // Visuals stay 28px: the wrapper is taller (hit-test area for the
    // overflowing dropdowns) but only the top strip is painted.
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: Qt.alpha(Foundations.glass.barBg, Settings.glassBarOpacity())
        height: root.barHeight
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.barHeight

        gradient: Gradient {
            orientation: Gradient.Vertical

            GradientStop {
                position: 0.0
                color: Qt.alpha("#ffffff", 0.16)
            }
            GradientStop {
                position: 0.45
                color: Qt.alpha("#ffffff", 0.04)
            }
            GradientStop {
                position: 1.0
                color: Qt.alpha("#ffffff", 0.0)
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        color: Qt.alpha("#ffffff", 0.45)
        height: 1
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: root.barHeight - 1
        color: Qt.alpha(Foundations.glass.barHairline, 0.6)
        height: 1
    }

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
