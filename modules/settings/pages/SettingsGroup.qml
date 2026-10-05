pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    default property alias rows: col.children

    implicitHeight: col.implicitHeight + 8

    Rectangle {
        anchors.fill: parent
        color: "#2e2e38"
        radius: 10
    }

    ColumnLayout {
        id: col

        anchors.fill: parent
        anchors.bottomMargin: 4
        anchors.topMargin: 4
        spacing: 0
    }
}
