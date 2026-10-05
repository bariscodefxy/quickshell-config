pragma ComponentBehavior: Bound

import qs.ds
import QtQuick
import QtQuick.Effects

Item {
    id: root

    property color color: Foundations.glass.barIcon
    property string name: ""
    property real size: 16

    signal clicked()

    property bool clickable: false

    implicitHeight: size
    implicitWidth: size
    height: size
    width: size

    Image {
        id: img

        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        mipmap: true
        source: root.name !== "" ? Qt.resolvedUrl(`macos/${name}.svg`) : ""
        sourceSize.height: 64
        sourceSize.width: 64
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        colorization: 1.0
        colorizationColor: root.color
        source: img
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        visible: root.clickable

        onClicked: root.clicked()
    }
}
