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
            iconColor: "#f5f5f7"
            iconName: "appearance"
            showSeparator: false
            subtitle: "Dial in the precise amount of translucency, from ultra-clear to fully tinted."
            title: "Liquid Glass"
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: glassRow.implicitHeight + 24

        Rectangle {
            anchors.fill: parent
            color: "#2c2c36"
            radius: 10
        }

        ColumnLayout {
            id: glassRow

            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                DsText.BodyM {
                    Layout.fillWidth: true
                    color: "#f5f5f7"
                    font.family: Foundations.font.family.sans
                    text: "Transparency"
                }

                DsText.BodyM {
                    color: "#a0a0ab"
                    font.family: Foundations.font.family.sans
                    text: `${Math.round(Settings.glass * 100)}%`
                }
            }

            Slider {
                Layout.fillWidth: true
                implicitHeight: 28
                from: 0
                to: 1
                value: Settings.glass

                onMoved: Settings.glass = value
            }

            RowLayout {
                Layout.fillWidth: true

                DsText.BodyS {
                    color: "#a0a0ab"
                    font.family: Foundations.font.family.sans
                    text: "Clear"
                }

                Item {
                    Layout.fillWidth: true
                }

                DsText.BodyS {
                    color: "#a0a0ab"
                    font.family: Foundations.font.family.sans
                    text: "Tinted"
                }
            }
        }
    }

    DsText.BodyS {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        color: "#a0a0ab"
        font.family: Foundations.font.family.sans
        text: "Applies to the menu bar and menus instantly. Saved to ~/.config/qsc/settings.json."
        wrapMode: Text.WordWrap
    }
}
