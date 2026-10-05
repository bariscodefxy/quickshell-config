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

    // Open menu geometry in window coordinates, for the shell input mask.
    // NOTE: read through the typed Bar reference — dynamic lookup on the
    // Item-typed Loader.item does not subscribe to change notifications
    // and would freeze at the startup value.
    readonly property Bar barItem: content.item
    readonly property rect menuGeo: barItem ? barItem.menuGeo : Qt.rect(0, 0, 0, 0)
    implicitHeight: root.contentHeight
    // Tall hit-test area: menu dropdowns overflow below the 28px bar and Qt
    // does not deliver mouse events into overflowing branches. implicitHeight
    // stays 28 so layout, exclusion zone and mask geometry are unaffected.
    height: root.barHeight + 340
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
