pragma ComponentBehavior: Bound

import qs.ds
import qs.ds.icons
import qs.ds.text as DsText
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property string title
    property string subtitle: ""
    property string iconName: ""
    property color iconColor: "#0a84ff"
    property bool showSeparator: true

    default property alias control: controlSlot.children

    implicitHeight: root.subtitle !== "" ? 60 : 52

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 52
        anchors.right: parent.right
        anchors.rightMargin: 12
        color: Qt.alpha("#ffffff", 0.08)
        height: 1
        visible: root.showSeparator
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        MacIcon {
            Layout.alignment: Qt.AlignVCenter
            color: root.iconColor
            name: root.iconName
            size: 20
            visible: root.iconName !== ""
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            spacing: 2

            DsText.BodyM {
                Layout.fillWidth: true
                color: "#f5f5f7"
                font.family: Foundations.font.family.sans
                text: root.title
            }

            DsText.BodyS {
                Layout.fillWidth: true
                color: "#a0a0ab"
                font.family: Foundations.font.family.sans
                text: root.subtitle
                visible: root.subtitle !== ""
                wrapMode: Text.WordWrap
            }
        }

        Item {
            id: controlSlot

            Layout.alignment: Qt.AlignVCenter
            implicitHeight: childrenRect.height
            implicitWidth: childrenRect.width
        }
    }
}
