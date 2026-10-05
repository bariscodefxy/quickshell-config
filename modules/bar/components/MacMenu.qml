pragma ComponentBehavior: Bound

import qs.ds
import qs.ds.icons
import qs.services
import QtQuick

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

    // Full dropdown height incl. padding (for the shell input mask).
    readonly property real dropdownHeight: listContent.height + 12

    signal closeRequested()
    signal openRequested(string name)

    readonly property bool isOpen: openMenu === menuName

    property int hoveredIndex: -1

    implicitWidth: (root.titleIcon !== "" ? root.titleIconSize : titleMetrics.width) + 16
    implicitHeight: 22

    onIsOpenChanged: {
        root.hoveredIndex = -1;
    }

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
        color: titleMouse.containsMouse || root.isOpen ? Qt.alpha(Foundations.glass.barText, root.isOpen ? 0.16 : 0.08) : "transparent"
        radius: 6
        z: -1
    }

    Text {
        id: title

        anchors.centerIn: parent
        color: Foundations.glass.barText
        font.family: root.titleFontFamily !== "" ? root.titleFontFamily : Foundations.font.family.sans
        font.pointSize: 10
        font.weight: root.titleBold ? Font.Bold : Font.Normal
        text: root.titleText
        visible: root.titleIcon === ""
    }

    MacIcon {
        anchors.centerIn: parent
        color: Foundations.glass.barText
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

    // Soft drop shadow under the frosted menu (layered rects: no
    // compositor blur available for a real shadow).
    Rectangle {
        id: shadow

        visible: root.isOpen
        x: 0
        y: parent.height + 6
        width: root.dropdownWidth
        height: listContent.height + 14
        radius: 13
        color: Qt.alpha("#000000", 0.14)
        z: 99
    }

    Rectangle {
        id: dropdown

        visible: root.isOpen
        x: 0
        y: parent.height + 4
        width: root.dropdownWidth
        height: listContent.height + 12
        radius: 12
        color: Qt.alpha(Foundations.glass.menuBg, Settings.glassMenuOpacity())
        border.width: 1
        border.color: Qt.alpha("#000000", 0.1)
        z: 100

        // Top-down sheen for the frosted-glass depth.
        Rectangle {
            anchors.fill: parent
            radius: parent.radius

            gradient: Gradient {
                orientation: Gradient.Vertical

                GradientStop {
                    position: 0.0
                    color: Qt.alpha("#ffffff", 0.14)
                }
                GradientStop {
                    position: 0.5
                    color: Qt.alpha("#ffffff", 0.0)
                }
            }
        }

        // Inner specular highlight along the top edge.
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 3
            anchors.right: parent.right
            anchors.rightMargin: 3
            anchors.top: parent.top
            anchors.topMargin: 1
            color: Qt.alpha("#ffffff", 0.5)
            height: 1
            radius: 1
        }

        Column {
            id: listContent

            anchors.centerIn: parent
            width: parent.width - 12

            Repeater {
                model: root.items

                delegate: Item {
                    id: del

                    required property int index
                    required property var modelData

                    height: del.modelData.separator === true ? 9 : 28
                    width: listContent.width

                    Rectangle {
                        anchors.centerIn: parent
                        color: Foundations.glass.menuSeparator
                        height: 1
                        visible: del.modelData.separator === true
                        width: parent.width - 8
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: root.hoveredIndex === del.index ? Foundations.glass.menuHover : "transparent"
                        radius: 7
                        visible: del.modelData.separator !== true
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.hoveredIndex === del.index ? Foundations.glass.menuHoverText : Foundations.glass.menuText
                        font.family: Foundations.font.family.sans
                        font.pointSize: 10
                        text: del.modelData.label ?? ""
                        visible: del.modelData.separator !== true
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        color: root.hoveredIndex === del.index ? Foundations.glass.menuHoverText : Foundations.glass.menuShortcut
                        font.family: Foundations.font.family.sans
                        font.pointSize: 10
                        text: del.modelData.shortcut ?? ""
                        visible: del.modelData.separator !== true
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: del.modelData.separator !== true
                        hoverEnabled: true

                        onClicked: {
                            const act = del.modelData.action;
                            root.closeRequested();
                            if (act)
                                act();
                        }
                        onEntered: root.hoveredIndex = del.index
                        onExited: {
                            if (root.hoveredIndex === del.index)
                                root.hoveredIndex = -1;
                        }
                    }
                }
            }
        }
    }
}
