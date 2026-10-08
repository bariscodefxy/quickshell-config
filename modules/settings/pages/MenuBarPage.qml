pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    spacing: 12

    component BarSwitch: SettingRow {
        id: row

        required property string key
        required property string label

        Layout.fillWidth: true
        title: row.label

        Switch {
            activeColor: "#30d158"
            activeThumbColor: "#ffffff"
            checked: Settings[row.key]
            inactiveBorderColor: GtkTheme.controlBg
            inactiveColor: GtkTheme.controlBg
            inactiveThumbColor: "#ffffff"

            onToggled: Settings[row.key] = checked
        }
    }

    SettingsGroup {
        Layout.fillWidth: true

        BarSwitch {
            key: "showAudio"
            label: "Sound"
        }

        BarSwitch {
            key: "showNetwork"
            label: "Wi-Fi"
        }

        BarSwitch {
            key: "showVpn"
            label: "VPN"
        }

        BarSwitch {
            key: "showBluetooth"
            label: "Bluetooth"
        }

        BarSwitch {
            key: "showBattery"
            label: "Battery"
        }

        BarSwitch {
            key: "showKbLayout"
            label: "Keyboard layout"
        }

        BarSwitch {
            key: "showTray"
            label: "App icons"
        }

        BarSwitch {
            key: "showSpotlight"
            label: "Spotlight"
            showSeparator: false
        }
    }

    SettingsGroup {
        Layout.fillWidth: true

        BarSwitch {
            key: "showDate"
            label: "Clock"
        }

        BarSwitch {
            key: "clock24h"
            label: "24-hour clock"
            showSeparator: false
        }
    }
}
