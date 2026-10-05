pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import qs.ds.buttons as Buttons
import qs.ds.text as DsText
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property list<string> files: []

    spacing: 12

    function scan(): void {
        scanProc.dir = Settings.expandHome(Settings.wallpaperDir);
        scanProc.running = false;
        scanProc.running = true;
    }

    Component.onCompleted: {
        root.scan();
    }

    SettingsGroup {
        Layout.fillWidth: true

        SettingRow {
            Layout.fillWidth: true
            iconColor: "#64d2ff"
            iconName: "image"
            showSeparator: false
            subtitle: Settings.wallpaper !== "" ? Settings.wallpaper : "No wallpaper set"
            title: "Current picture"
        }
    }

    SettingsGroup {
        Layout.fillWidth: true

        SettingRow {
            Layout.fillWidth: true
            iconColor: "#8e8e93"
            iconName: "menubar"
            subtitle: "Fill crops to screen, Fit shows the whole picture."
            title: "Fill screen"

            Switch {
                activeColor: "#30d158"
                activeThumbColor: "#ffffff"
                checked: Settings.wallpaperMode === "fill"
                inactiveBorderColor: "#48484e"
                inactiveColor: "#48484e"
                inactiveThumbColor: "#ffffff"

                onToggled: {
                    Settings.wallpaperMode = checked ? "fill" : "fit";
                    Settings.applyWallpaper();
                }
            }
        }

        SettingRow {
            Layout.fillWidth: true
            iconColor: "#8e8e93"
            iconName: "gear"
            showSeparator: false
            subtitle: "Rescan the folder for new pictures."
            title: "Folder"

            Buttons.Button {
                backgroundColor: "#48484e"
                foregroundColor: "#ffffff"
                text: "Rescan"

                onClicked: {
                    root.scan();
                }
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 300

        Rectangle {
            anchors.fill: parent
            color: "#2e2e38"
            radius: 10
        }

        GridView {
            id: grid

            anchors.fill: parent
            anchors.margins: 12
            cellHeight: 120
            cellWidth: 168
            clip: true
            model: root.files

            delegate: Item {
                id: cell

                required property string modelData

                height: 120
                width: 168

                readonly property bool isCurrent: Settings.wallpaper === cell.modelData

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    border.color: cell.isCurrent ? "#0a84ff" : "transparent"
                    border.width: 3
                    color: "#1c1c22"
                    radius: 8
                }

                Image {
                    anchors.fill: parent
                    anchors.margins: 4
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    source: `file://${cell.modelData}`
                    sourceSize.height: 220
                    sourceSize.width: 320
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    color: "transparent"
                    radius: 8

                    border.color: cell.isCurrent ? "#0a84ff" : Qt.alpha("#ffffff", 0.12)
                    border.width: cell.isCurrent ? 3 : 1
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        Settings.setWallpaper(cell.modelData);
                    }
                }
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8
            visible: root.files.length === 0
            width: parent.width - 48

            DsText.BodyM {
                Layout.alignment: Qt.AlignHCenter
                color: "#f5f5f7"
                font.family: Foundations.font.family.sans
                horizontalAlignment: Text.AlignHCenter
                text: "No pictures found"
            }

            DsText.BodyS {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                color: "#a0a0ab"
                font.family: Foundations.font.family.sans
                horizontalAlignment: Text.AlignHCenter
                text: `Put images in ${Settings.wallpaperDir}`
                wrapMode: Text.WordWrap
            }

            Buttons.Button {
                Layout.alignment: Qt.AlignHCenter
                backgroundColor: "#0a84ff"
                foregroundColor: "#ffffff"
                text: "Create folder"

                onClicked: {
                    Quickshell.execDetached(["sh", "-c", `mkdir -p ${Settings.shellQuote(Settings.expandHome(Settings.wallpaperDir))} && xdg-open ${Settings.shellQuote(Settings.expandHome(Settings.wallpaperDir))}`]);
                }
            }
        }
    }

    Process {
        id: scanProc

        property string dir: ""

        command: ["sh", "-c", `find ${Settings.shellQuote(scanProc.dir)} -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) 2>/dev/null | sort`]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                root.files = text.trim() === "" ? [] : text.trim().split("\n");
            }
        }
    }
}
