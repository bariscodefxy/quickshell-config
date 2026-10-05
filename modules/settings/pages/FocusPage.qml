pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import qs.ds.text as DsText
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    spacing: 12

    SettingsGroup {
        Layout.fillWidth: true

        SettingRow {
            Layout.fillWidth: true
            iconColor: "#5e5ce6"
            iconName: "moon"
            showSeparator: false
            subtitle: "Keep the display awake and block idle actions while enabled."
            title: "Stay Awake"

            Switch {
                activeColor: "#30d158"
                activeThumbColor: "#ffffff"
                checked: IdleInhibitor.enabled
                inactiveBorderColor: "#48484e"
                inactiveColor: "#48484e"
                inactiveThumbColor: "#ffffff"

                onToggled: IdleInhibitor.enabled = checked
            }
        }
    }

    DsText.BodyS {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        color: "#a0a0ab"
        font.family: Foundations.font.family.sans
        text: "Same switch as the menu bar moon icon. Persists only for this session."
        wrapMode: Text.WordWrap
    }
}
