pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import qs.ds.buttons as Buttons
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
            iconColor: GtkTheme.contentText
            iconName: "appearance"
            showSeparator: false
            subtitle: "Dial in the precise amount of translucency, from ultra-clear to fully tinted."
            title: "Liquid Glass"
        }
    }

    SettingsGroup {
        Layout.fillWidth: true

        SettingRow {
            Layout.fillWidth: true
            iconColor: "#64d2ff"
            iconName: "appearance"
            subtitle: "Follow the settings.ini files (for external tools)."
            title: "System"

            Buttons.RadioButton {
                checked: Settings.themeMode === "system"

                onClicked: {
                    if (Settings.themeMode !== "system")
                        Settings.setThemeMode("system");
                }
            }
        }

        SettingRow {
            Layout.fillWidth: true
            iconColor: GtkTheme.contentText
            iconName: "appearance"
            subtitle: "WhiteSur-Light for shell and apps, applied instantly."
            title: "Light"

            Buttons.RadioButton {
                checked: Settings.themeMode === "light"

                onClicked: {
                    if (Settings.themeMode !== "light")
                        Settings.setThemeMode("light");
                }
            }
        }

        SettingRow {
            Layout.fillWidth: true
            iconColor: "#8e8e93"
            iconName: "appearance"
            showSeparator: false
            subtitle: "WhiteSur-Dark for shell and apps, applied instantly."
            title: "Dark"

            Buttons.RadioButton {
                checked: Settings.themeMode === "dark"

                onClicked: {
                    if (Settings.themeMode !== "dark")
                        Settings.setThemeMode("dark");
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: glassRow.implicitHeight + 24

        Rectangle {
            anchors.fill: parent
            color: GtkTheme.cardBg
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
                    color: GtkTheme.contentText
                    font.family: Foundations.font.family.sans
                    text: "Transparency"
                }

                DsText.BodyM {
                    color: GtkTheme.contentTextDim
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
                    color: GtkTheme.contentTextDim
                    font.family: Foundations.font.family.sans
                    text: "Clear"
                }

                Item {
                    Layout.fillWidth: true
                }

                DsText.BodyS {
                    color: GtkTheme.contentTextDim
                    font.family: Foundations.font.family.sans
                    text: "Tinted"
                }
            }
        }
    }

    DsText.BodyS {
        Layout.fillWidth: true
        Layout.leftMargin: 12
        color: GtkTheme.contentTextDim
        font.family: Foundations.font.family.sans
        text: "Light/Dark rewrites the GTK theme (settings.ini + dconf) so apps follow; running apps pick it up on restart, shell icons after a shell restart. nix-config never selects a theme — the shell re-applies its own on every start. Saved to ~/.config/qsc/settings.json."
        wrapMode: Text.WordWrap
    }
}
