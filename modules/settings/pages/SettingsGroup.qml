pragma ComponentBehavior: Bound

import qs.services
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    default property alias rows: col.children

    implicitHeight: col.implicitHeight + 8

    Rectangle {
        anchors.fill: parent
        color: GtkTheme.cardBg
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
