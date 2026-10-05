pragma ComponentBehavior: Bound

import "services"
import qs.services
import qs.ds
import qs.ds.text as DsText
import qs.ds.icons as Icons
import qs.ds.buttons.circularButtons as CircularButtons
import qs.ds.animations
import Quickshell
import QtQuick

Item {
    id: root

    required property var panels
    required property PersistentProperties visibilities
    required property var wrapper

    readonly property int itemWidth: 600
    readonly property int padding: Foundations.spacing.l
    readonly property int innerMargin: Foundations.spacing.s

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    implicitHeight: searchBox.height + listWrapper.height + padding * 2 + innerMargin
    implicitWidth: listWrapper.width + padding * 2

    Behavior on implicitHeight {
        enabled: false
    }

    Item {
        id: searchBox

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: root.padding
        height: 44
        width: root.itemWidth

        Icons.MaterialFontIcon {
            id: searchIcon

            anchors.left: parent.left
            anchors.leftMargin: Foundations.spacing.m
            anchors.verticalCenter: parent.verticalCenter
            color: Foundations.palette.base04
            text: "search"
        }

        TextField {
            id: searchField

            anchors.left: searchIcon.right
            anchors.leftMargin: Foundations.spacing.s
            anchors.right: clearButton.left
            anchors.rightMargin: Foundations.spacing.s
            anchors.verticalCenter: parent.verticalCenter
            background: null
            backgroundColor: "transparent"
            font.pointSize: Foundations.font.size.s
            borderWidth: 0
            bottomPadding: Foundations.spacing.xs
            placeholderText: "Spotlight Search"
            text: root.visibilities.searchText
            topPadding: Foundations.spacing.xs

            Keys.onDownPressed: {
                const list = root.visibilities.launcherList;
                if (list)
                    list.incrementCurrentIndex();
            }
            Keys.onEscapePressed: {
                root.visibilities.launcher = false;
            }
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Return && (event.modifiers & Qt.ShiftModifier)) {
                    const list = root.visibilities.launcherList;
                    const currentItem = list?.currentItem;
                    if (currentItem && currentItem.hintButton) {
                        currentItem.hintButton.clicked();
                        event.accepted = true;
                    }
                }

                if (event.key === Qt.Key_Delete && (event.modifiers & Qt.ShiftModifier)) {
                    const list = root.visibilities.launcherList;
                    const onDelete = list?.currentItem?.modelData?.onDelete;
                    if (onDelete) {
                        list.restoreIndex = Math.max(0, list.currentIndex - 1);
                        onDelete();
                        event.accepted = true;
                    }
                }
            }
            Keys.onUpPressed: {
                const list = root.visibilities.launcherList;
                if (list)
                    list.decrementCurrentIndex();
            }

            onAccepted: {
                const list = root.visibilities.launcherList;
                const currentItem = list?.currentItem;
                if (currentItem)
                    currentItem.activate();
            }
            onTextChanged: {
                root.visibilities.searchText = text;
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.IBeamCursor
                enabled: !searchField.activeFocus

                onClicked: {
                    searchField.forceActiveFocus();
                }
            }
        }

        CircularButtons.M {
            id: clearButton

            anchors.right: parent.right
            anchors.rightMargin: Foundations.spacing.m
            anchors.verticalCenter: parent.verticalCenter
            icon: "close"
            opacity: searchField.text ? 1 : 0
            visible: searchField.text

            Behavior on opacity {
                BasicNumberAnimation {
                }
            }

            onClicked: {
                root.visibilities.searchText = "";
                searchField.forceActiveFocus();
            }
        }
    }

    Item {
        id: listWrapper

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: searchBox.bottom
        anchors.topMargin: root.innerMargin
        implicitHeight: list.height + root.padding
        implicitWidth: list.width

        ContentList {
            id: list

            padding: root.padding
            panels: root.panels
            searchText: root.visibilities.searchText
            visibilities: root.visibilities
            wrapper: root.wrapper
        }
    }

    Timer {
        id: focusTimer

        interval: 50
        repeat: false

        onTriggered: {
            if (root.visibilities.launcher)
                searchField.forceActiveFocus();
        }
    }

    Connections {
        function onLauncherChanged(): void {
            if (root.visibilities.launcher) {
                focusTimer.start();
            } else {
                root.visibilities.searchText = "";
                const list = root.visibilities.launcherList;
                if (list)
                    list.currentIndex = 0;
            }
        }

        target: root.visibilities
    }
}
