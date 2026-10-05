pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string hostname: ""
    property string kernel: ""
    property string uptime: ""

    spacing: 12

    Component.onCompleted: {
        hostnameProc.running = true;
        kernelProc.running = true;
        uptimeProc.running = true;
    }

    SettingsGroup {
        Layout.fillWidth: true

        SettingRow {
            Layout.fillWidth: true
            iconColor: "#8e8e93"
            iconName: "person"
            subtitle: Quickshell.env("USER") || "user"
            title: "User"
        }

        SettingRow {
            Layout.fillWidth: true
            iconColor: "#8e8e93"
            iconName: "menubar"
            subtitle: root.hostname !== "" ? root.hostname : "…"
            title: "Host"
        }

        SettingRow {
            Layout.fillWidth: true
            iconColor: "#8e8e93"
            iconName: "gear"
            subtitle: root.kernel !== "" ? root.kernel : "…"
            title: "Kernel"
        }

        SettingRow {
            Layout.fillWidth: true
            iconColor: "#8e8e93"
            iconName: "bell"
            showSeparator: false
            subtitle: root.uptime !== "" ? root.uptime : "…"
            title: "Uptime"
        }
    }

    Process {
        id: hostnameProc

        command: ["hostname"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: root.hostname = text.trim()
        }
    }

    Process {
        id: kernelProc

        command: ["uname", "-r"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: root.kernel = text.trim()
        }
    }

    Process {
        id: uptimeProc

        command: ["uptime", "-p"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: root.uptime = text.trim()
        }
    }
}
