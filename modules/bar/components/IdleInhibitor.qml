pragma ComponentBehavior: Bound

import qs.ds
import qs.ds.icons
import qs.services
import Quickshell
import QtQuick

Item {
    id: root

    implicitHeight: 26
    implicitWidth: 26

    Rectangle {
        anchors.centerIn: parent
        color: IdleInhibitor.enabled ? GtkTheme.barText : "transparent"
        height: 24
        radius: 12
        width: 24
    }

    ThemeIcon {
        anchors.centerIn: parent
        color: IdleInhibitor.enabled ? "#ffffff" : GtkTheme.barIcon
        fallback: "moon"
        name: "weather-clear-night-symbolic"
        size: 14
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            IdleInhibitor.enabled = !IdleInhibitor.enabled;
        }
    }
}
