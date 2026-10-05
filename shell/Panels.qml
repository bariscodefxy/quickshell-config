import qs.ds
import qs.modules.notifications as NotificationsList
import qs.modules.launcher as Launcher
import qs.modules.settings as Settings
import qs.modules.dock as Dock
import qs.modules.popups as Popups
import Quickshell
import QtQuick

Item {
    id: root

    required property Item bar
    readonly property Launcher.Wrapper launcher: launcher
    readonly property NotificationsList.Wrapper notifications: notifications
    readonly property Settings.Wrapper settings: settings
    readonly property Dock.Wrapper dock: dock
    readonly property Popups.Wrapper popouts: popouts
    required property ShellScreen screen
    required property PersistentProperties visibilities
    required property int margin

    anchors.fill: parent
    anchors.margins: margin
    anchors.topMargin: bar.implicitHeight

    Launcher.Wrapper {
        id: launcher

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        panels: root
        visibilities: root.visibilities
    }
    NotificationsList.Wrapper {
        id: notifications

        anchors.right: parent.right
        anchors.top: parent.top
        panels: root
        visibilities: root.visibilities
    }
    Settings.Wrapper {
        id: settings

        anchors.centerIn: parent
        panels: root
        screen: root.screen
        visibilities: root.visibilities
    }
    Dock.Wrapper {
        id: dock

        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.margin
        anchors.horizontalCenter: parent.horizontalCenter
        margin: root.margin
        panels: root
        screen: root.screen
        visibilities: root.visibilities
    }
    Popups.Wrapper {
        id: popouts

        screen: root.screen
        x: {
            const off = currentCenter - root.margin - nonAnimWidth / 2;
            const diff = root.width - Math.floor(off + nonAnimWidth);
            if (diff < 0)
                return off + diff;
            return Math.max(off, 0);
        }
        y: 0
    }
}
