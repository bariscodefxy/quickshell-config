pragma ComponentBehavior: Bound

import qs.ds
import qs.ds.icons
import qs.ds.text as DsText
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property string currentPage
    required property string filter

    signal pageRequested(string id)

    readonly property var pages: [
        { id: "wifi", label: "Wi-Fi", icon: "wifi", color: "#0a84ff" },
        { id: "bluetooth", label: "Bluetooth", icon: "bluetooth", color: "#0a84ff" },
        { id: "vpn", label: "VPN", icon: "key", color: "#0a84ff" },
        { id: "battery", label: "Battery", icon: "battery", color: "#30d158" },
        { id: "general", label: "General", icon: "gear", color: "#8e8e93" },
        { id: "appearance", label: "Appearance", icon: "appearance", color: "#f5f5f7" },
        { id: "wallpaper", label: "Wallpaper", icon: "image", color: "#64d2ff" },
        { id: "menubar", label: "Menu Bar", icon: "menubar", color: "#8e8e93" },
        { id: "sound", label: "Sound", icon: "volume-high", color: "#ff375f" },
        { id: "keyboard", label: "Keyboard", icon: "keyboard", color: "#8e8e93" },
        { id: "notifications", label: "Notifications", icon: "bell", color: "#ff453a" },
        { id: "focus", label: "Focus", icon: "moon", color: "#5e5ce6" }
    ]

    readonly property var visiblePages: root.pages.filter(p => p.label.toLowerCase().includes(root.filter.toLowerCase()))

    implicitHeight: layout.implicitHeight
    implicitWidth: 230

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: 2

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: accountRow.implicitHeight + 16

            RowLayout {
                id: accountRow

                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 8
                spacing: 10

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    color: "#48484e"
                    height: 40
                    radius: 20
                    width: 40

                    MacIcon {
                        anchors.centerIn: parent
                        color: "#c7c7cc"
                        name: "person"
                        size: 24
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    spacing: 1

                    DsText.BodyM {
                        color: "#f5f5f7"
                        font.family: Foundations.font.family.sans
                        text: Quickshell.env("USER") || "user"
                    }

                    DsText.BodyS {
                        color: "#a0a0ab"
                        font.family: Foundations.font.family.sans
                        text: "Linux Account"
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: root.pageRequested("general")
            }
        }

        Repeater {
            model: root.visiblePages

            delegate: Item {
                id: row

                required property var modelData

                Layout.fillWidth: true
                implicitHeight: 34

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    color: root.currentPage === row.modelData.id ? "#0a84ff" : (rowMouse.containsMouse ? Qt.alpha("#ffffff", 0.08) : "transparent")
                    radius: 8
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 10

                    Rectangle {
                        Layout.alignment: Qt.AlignVCenter
                        color: row.modelData.color
                        height: 28
                        radius: 7
                        width: 28

                        MacIcon {
                            anchors.centerIn: parent
                            color: "#ffffff"
                            name: row.modelData.icon
                            size: 15
                        }
                    }

                    DsText.BodyM {
                        Layout.alignment: Qt.AlignVCenter
                        Layout.fillWidth: true
                        color: "#f5f5f7"
                        font.family: Foundations.font.family.sans
                        text: row.modelData.label
                    }
                }

                MouseArea {
                    id: rowMouse

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true

                    onClicked: root.pageRequested(row.modelData.id)
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
