pragma ComponentBehavior: Bound

import qs.ds
import qs.ds.icons
import QtQuick

Item {
    id: root

    property real level: 1.0
    property bool charging: false
    property color color: Foundations.glass.barIcon
    property color lowColor: Foundations.palette.base08
    property color boltColor: "#f5f5f7"

    readonly property real clamped: Math.max(0, Math.min(1, root.level))
    readonly property color fillColor: (!root.charging && root.clamped <= 0.2) ? root.lowColor : root.color

    implicitHeight: 12
    implicitWidth: 27
    height: 12
    width: 27

    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        border.color: root.fillColor
        border.width: 1.2
        color: "transparent"
        height: 12
        radius: 3.5
        width: 23
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        color: root.fillColor
        height: 8
        radius: 2
        visible: root.clamped > 0.02
        width: Math.max(2, 19 * root.clamped)
        x: 2
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        color: root.fillColor
        height: 4
        radius: 1.2
        width: 2.5
        x: 24
    }

    MacIcon {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: -1
        color: root.boltColor
        name: "bolt"
        size: 9
        visible: root.charging
    }
}
