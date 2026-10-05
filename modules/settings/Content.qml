pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import qs.ds.text as DsText
import qs.ds.icons as Icons
import Quickshell
import QtQuick
import QtQuick.Layouts
import "pages" as Pages

Rectangle {
    id: root

    required property var panels
    required property ShellScreen screen
    required property PersistentProperties visibilities
    required property var wrapper

    property string currentPage: "wifi"
    property string filter: ""
    property var history: ["wifi"]
    property int histIndex: 0
    property bool zoomed: true

    readonly property real fullWidth: Math.min(940, screen.width - 64)
    readonly property real fullHeight: Math.min(640, screen.height - 100)

    function pageTitle(id: string): string {
        const titles = {
            wifi: "Wi-Fi",
            bluetooth: "Bluetooth",
            vpn: "VPN",
            battery: "Battery",
            general: "General",
            appearance: "Appearance",
            wallpaper: "Wallpaper",
            menubar: "Menu Bar",
            sound: "Sound",
            keyboard: "Keyboard",
            notifications: "Notifications",
            focus: "Focus"
        };
        return titles[id] ?? id;
    }

    function goTo(id: string): void {
        if (id === root.currentPage)
            return;
        root.history = root.history.slice(0, root.histIndex + 1).concat([id]);
        root.histIndex = root.history.length - 1;
        root.currentPage = id;
    }

    function goBack(): void {
        if (root.histIndex > 0) {
            root.histIndex--;
            root.currentPage = root.history[root.histIndex];
        }
    }

    function goForward(): void {
        if (root.histIndex < root.history.length - 1) {
            root.histIndex++;
            root.currentPage = root.history[root.histIndex];
        }
    }

    function pageComponent(id: string): Component {
        switch (id) {
        case "wifi":
            return wifiComp;
        case "bluetooth":
            return bluetoothComp;
        case "vpn":
            return vpnComp;
        case "battery":
            return batteryComp;
        case "general":
            return generalComp;
        case "appearance":
            return appearanceComp;
        case "wallpaper":
            return wallpaperComp;
        case "menubar":
            return menubarComp;
        case "sound":
            return soundComp;
        case "keyboard":
            return keyboardComp;
        case "notifications":
            return notificationsComp;
        case "focus":
            return focusComp;
        default:
            return wifiComp;
        }
    }

    color: "#24242e"
    implicitHeight: root.fullHeight
    implicitWidth: root.zoomed ? root.fullWidth : Math.min(700, root.fullWidth)
    radius: 12

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Foundations.duration.fast
            easing.type: Easing.InOutQuad
        }
    }

    border.color: Qt.alpha("#000000", 0.4)
    border.width: 1

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Sidebar
        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: 240
            spacing: 8

            TrafficLights {
                Layout.leftMargin: 16
                Layout.topMargin: 14
                visibilities: root.visibilities

                onCloseRequested: root.visibilities.settings = false
                onMinimizeRequested: root.visibilities.settings = false
                onZoomToggled: root.zoomed = !root.zoomed
            }

            Item {
                Layout.fillWidth: true
                Layout.leftMargin: 12
                Layout.preferredHeight: 32
                Layout.rightMargin: 12

                Rectangle {
                    anchors.fill: parent
                    color: "#38383f"
                    radius: 8
                }

                Icons.MaterialFontIcon {
                    id: sideSearchIcon

                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    color: "#8e8e93"
                    text: "search"
                }

                TextField {
                    id: sideSearch

                    anchors.left: sideSearchIcon.right
                    anchors.leftMargin: 4
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    background: null
                    backgroundColor: "transparent"
                    font.pointSize: Foundations.font.size.s
                    borderWidth: 0
                    bottomPadding: 4
                    placeholderText: "Search"
                    topPadding: 4

                    Keys.onEscapePressed: {
                        root.visibilities.settings = false;
                    }

                    onTextChanged: {
                        root.filter = text;
                    }
                }
            }

            Sidebar {
                Layout.fillHeight: true
                Layout.fillWidth: true
                currentPage: root.currentPage
                filter: root.filter

                onPageRequested: id => root.goTo(id)
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Qt.alpha("#ffffff", 0.08)
        }

        // Detail
        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.topMargin: 14
                Layout.bottomMargin: 12
                spacing: 6

                NavButton {
                    glyph: "‹"
                    active: root.histIndex > 0

                    onClicked: root.goBack()
                }

                NavButton {
                    glyph: "›"
                    active: root.histIndex < root.history.length - 1

                    onClicked: root.goForward()
                }

                DsText.HeadingM {
                    Layout.fillWidth: true
                    Layout.leftMargin: 6
                    color: "#f5f5f7"
                    font.family: Foundations.font.family.sans
                    text: root.pageTitle(root.currentPage)
                }
            }

            Flickable {
                id: flick

                Layout.bottomMargin: 20
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                clip: true
                contentHeight: pageLoader.item?.implicitHeight ?? 0
                contentWidth: width

                Loader {
                    id: pageLoader

                    width: flick.width
                    sourceComponent: root.pageComponent(root.currentPage)
                }
            }
        }
    }

    Timer {
        id: focusTimer

        interval: 80
        repeat: false

        onTriggered: {
            if (root.visibilities.settings)
                sideSearch.forceActiveFocus();
        }
    }

    Connections {
        function onSettingsChanged(): void {
            if (root.visibilities.settings) {
                root.filter = "";
                sideSearch.text = "";
                focusTimer.start();
            }
        }

        target: root.visibilities
    }

    Component {
        id: wifiComp

        Pages.WifiPage {
        }
    }

    Component {
        id: bluetoothComp

        Pages.BluetoothPage {
        }
    }

    Component {
        id: vpnComp

        Pages.VpnPage {
        }
    }

    Component {
        id: batteryComp

        Pages.BatteryPage {
        }
    }

    Component {
        id: generalComp

        Pages.GeneralPage {
        }
    }

    Component {
        id: appearanceComp

        Pages.AppearancePage {
        }
    }

    Component {
        id: wallpaperComp

        Pages.WallpaperPage {
        }
    }

    Component {
        id: menubarComp

        Pages.MenuBarPage {
        }
    }

    Component {
        id: soundComp

        Pages.SoundPage {
        }
    }

    Component {
        id: keyboardComp

        Pages.KeyboardPage {
        }
    }

    Component {
        id: notificationsComp

        Pages.NotificationsPage {
            visibilities: root.visibilities

            onCloseWindow: root.visibilities.settings = false
        }
    }

    Component {
        id: focusComp

        Pages.FocusPage {
        }
    }

    component NavButton: Rectangle {
        id: nav

        signal clicked()

        property string glyph: ""
        property bool active: true

        color: navMouse.containsMouse && nav.active ? Qt.alpha("#ffffff", 0.12) : "transparent"
        implicitHeight: 26
        implicitWidth: 30
        opacity: nav.active ? 1 : 0.35
        radius: 6

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -1
            color: "#c7c7cc"
            font.pointSize: 16
            text: nav.glyph
        }

        MouseArea {
            id: navMouse

            anchors.fill: parent
            cursorShape: nav.active ? Qt.PointingHandCursor : Qt.ArrowCursor
            hoverEnabled: true

            onClicked: {
                if (nav.active)
                    nav.clicked();
            }
        }
    }
}
