pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import qs.ds.buttons as Buttons
import qs.ds.text as DsText
import Quickshell
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    required property PersistentProperties visibilities

    signal closeWindow()

    spacing: 12

    SettingsGroup {
        Layout.fillWidth: true

        SettingRow {
            Layout.fillWidth: true
            iconColor: "#ff453a"
            iconName: "bell"
            subtitle: "Silence banners and sounds as they arrive."
            title: "Do Not Disturb"

            Switch {
                activeColor: "#30d158"
                activeThumbColor: "#ffffff"
                checked: NotificationService.doNotDisturb
                inactiveBorderColor: GtkTheme.controlBg
                inactiveColor: GtkTheme.controlBg
                inactiveThumbColor: "#ffffff"

                onToggled: NotificationService.doNotDisturb = checked
            }
        }

        SettingRow {
            Layout.fillWidth: true
            iconColor: "#0a84ff"
            iconName: "menubar"
            subtitle: `${NotificationService.notifications.length} stored notifications`
            title: "Notification Center"

            Buttons.Button {
                backgroundColor: "#0a84ff"
                foregroundColor: GtkTheme.contentText
                text: "Open"

                onClicked: {
                    root.visibilities.notifications = true;
                    root.closeWindow();
                }
            }
        }

        SettingRow {
            Layout.fillWidth: true
            iconColor: "#ff9f0a"
            iconName: "bell-slash"
            showSeparator: false
            subtitle: "Dismiss everything currently stored."
            title: "Clear all"

            Buttons.Button {
                backgroundColor: GtkTheme.controlBg
                foregroundColor: GtkTheme.contentText
                text: "Clear"

                onClicked: {
                    NotificationService.clearNotifications();
                }
            }
        }
    }
}
