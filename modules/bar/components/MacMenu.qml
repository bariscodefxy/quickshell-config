pragma ComponentBehavior: Bound

import qs.ds
import qs.ds.icons
import qs.services
import QtQuick

// Menu-bar title (Apple logo, app name, File/Edit/...). The dropdown itself
// lives in shell/MenuWindow.qml (separate layer window): a dropdown rendered
// here would overflow the 28px bar and Qt does not deliver mouse events into
// overflowing branches, making items unclickable.
Item {
    id: root

    required property var items
    required property string menuName
    required property string openMenu
    required property string titleText
    property bool titleBold: false
    property string titleFontFamily: ""
    property string titleIcon: ""
    property real titleIconSize: 14
    property int dropdownWidth: 250

    signal closeRequested()
    signal openRequested(string name)

    readonly property bool isOpen: openMenu === menuName

    implicitWidth: (root.titleIcon !== "" ? root.titleIconSize : titleMetrics.width) + 16
    implicitHeight: 22

    TextMetrics {
        id: titleMetrics

        font.family: root.titleFontFamily !== "" ? root.titleFontFamily : Foundations.font.family.sans
        font.pointSize: 10
        font.weight: root.titleBold ? Font.Bold : Font.Normal
        text: root.titleText
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        color: titleMouse.containsMouse || root.isOpen ? Qt.alpha(GtkTheme.barText, root.isOpen ? 0.16 : 0.08) : "transparent"
        radius: 6
        z: -1
    }

    Text {
        id: title

        anchors.centerIn: parent
        color: GtkTheme.barText
        font.family: root.titleFontFamily !== "" ? root.titleFontFamily : Foundations.font.family.sans
        font.pointSize: 10
        font.weight: root.titleBold ? Font.Bold : Font.Normal
        text: root.titleText
        visible: root.titleIcon === ""
    }

    MacIcon {
        anchors.centerIn: parent
        color: GtkTheme.barText
        name: root.titleIcon
        size: root.titleIconSize
        visible: root.titleIcon !== ""
    }

    MouseArea {
        id: titleMouse

        anchors.fill: parent
        hoverEnabled: true

        onClicked: {
            if (root.isOpen)
                root.closeRequested();
            else
                root.openRequested(root.menuName);
        }
        onEntered: {
            if (root.openMenu !== "" && !root.isOpen)
                root.openRequested(root.menuName);
        }
    }
}
