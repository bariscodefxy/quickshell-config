pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

Item {
    id: root

    required property PersistentProperties visibilities
    property bool zoomed: true

    signal closeRequested()
    signal minimizeRequested()
    signal zoomToggled()

    implicitHeight: 14
    implicitWidth: 52

    property bool hovering: closeArea.containsMouse || minArea.containsMouse || zoomArea.containsMouse

    Row {
        anchors.centerIn: parent
        spacing: 8

        Light {
            color: "#ff5f57"
            glyph: "×"
            showGlyph: root.hovering

            MouseArea {
                id: closeArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked: root.closeRequested()
            }
        }
        Light {
            color: "#febc2e"
            glyph: "–"
            showGlyph: root.hovering

            MouseArea {
                id: minArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked: root.minimizeRequested()
            }
        }
        Light {
            color: "#28c840"
            glyph: "+"
            showGlyph: root.hovering

            MouseArea {
                id: zoomArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked: root.zoomToggled()
            }
        }
    }

    component Light: Rectangle {
        id: light

        required property color color
        required property string glyph
        required property bool showGlyph

        color: light.color
        height: 12
        radius: 6
        width: 12

        border.color: Qt.alpha("#000000", 0.25)
        border.width: 1

        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -0.5
            color: Qt.alpha("#000000", 0.6)
            font.pointSize: 9
            text: light.glyph
            visible: light.showGlyph
        }
    }
}
