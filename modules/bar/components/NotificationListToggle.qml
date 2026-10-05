pragma ComponentBehavior: Bound

import qs.ds
import qs.ds.icons
import qs.services
import Quickshell
import QtQuick

Item {
    id: root

    required property var visibilities
    readonly property bool enabled: root.visibilities.notifications

    implicitHeight: 26
    implicitWidth: 26

    Rectangle {
        anchors.centerIn: parent
        color: root.enabled ? Foundations.glass.barText : "transparent"
        height: 24
        radius: 12
        width: 24
    }

    ThemeIcon {
        anchors.centerIn: parent
        color: root.enabled ? "#ffffff" : Foundations.glass.barIcon
        fallback: NotificationService.doNotDisturb ? "bell-slash" : "bell"
        name: "notification-symbolic"
        size: 15
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.visibilities.notifications = !root.visibilities.notifications;
        }
    }
}
