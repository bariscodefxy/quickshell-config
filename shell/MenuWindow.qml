pragma ComponentBehavior: Bound

import qs.ds
import qs.services
import Quickshell
import Quickshell.Wayland
import QtQuick

// Open menu-bar dropdown as its own layer window. A dropdown rendered inside
// the 28px bar overflows it and Qt does not deliver mouse events into
// overflowing branches; a mask region alone cannot fix hit-testing. This
// window has no mask (full input) and exactly covers the menu.
PanelWindow {
    id: root

    required property int menuW
    required property int menuX
    required property int menuY
    required property var menuItems
    required property bool open
    required property ShellScreen screen

    signal closeRequested()

    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: `quickshell-drawers`
    anchors.left: true
    anchors.top: true
    color: "transparent"
    margins.left: root.menuX
    margins.top: root.menuY
    screen: root.screen
    visible: root.open

    property int hoveredIndex: -1

    onMenuItemsChanged: root.hoveredIndex = -1
    onOpenChanged: root.hoveredIndex = -1

    implicitWidth: root.menuW
    implicitHeight: list.height + 12

    // Frosted menu box.
    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Qt.alpha(Foundations.glass.menuBg, Settings.glassMenuOpacity())
        border.width: 1
        border.color: Qt.alpha("#000000", 0.1)

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
    }

    // Clicks on padding dismiss the menu.
    MouseArea {
        anchors.fill: parent

        onPressed: root.closeRequested()
    }

    Column {
        id: list

        anchors.centerIn: parent
        width: parent.width - 12

        Repeater {
            model: root.menuItems

            delegate: Item {
                id: del

                required property int index
                required property var modelData

                height: del.modelData.separator === true ? 9 : 28
                width: list.width

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
