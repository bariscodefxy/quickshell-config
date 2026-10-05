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
    implicitHeight: root.contentHeight
    visible: true

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Foundations.glass.barBg, Settings.glassBarOpacity())
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
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
