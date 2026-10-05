pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import qs.ds.icons
import qs.modules.popups as BarPopouts
import qs.modules.bar.components
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property int innerHeight
    required property BarPopouts.Wrapper popouts
    required property ShellScreen screen
    required property PersistentProperties visibilities

    property string openMenu: ""

    function closeMenus(): void {
        root.openMenu = "";
    }

    function checkPopout(x: real): void {
        const ch = mainLayout.childAt(x, height / 2) as WrappedLoader;
        if (!ch) {
            return;
        }

        const id = ch.id;
        const left = ch.x;
        const item = ch.item;
        const itemWidth = item.implicitWidth;

        if (id === "statusIcons") {
            const items = item.items;
            const icon = items.childAt(mapToItem(items, x, 0).x, items.height / 2);
            if (icon) {
                root.openMenu = "";
                popouts.currentName = icon.name;
                popouts.currentCenter = Qt.binding(() => icon.mapToItem(root, icon.implicitWidth / 2, 0).x);
                popouts.hasCurrent = true;
            }
        } else if (id === "tray") {
            const index = Math.floor(((x - left) / itemWidth) * item.items.count);
            const trayItem = item.items.itemAt(index);
            if (trayItem) {
                root.openMenu = "";
                popouts.currentName = `traymenu${index}`;
                popouts.currentCenter = Qt.binding(() => trayItem.mapToItem(root, trayItem.implicitWidth / 2, 0).x);
                popouts.hasCurrent = true;
            }
        } else if (id === "date") {
            root.openMenu = "";
            popouts.currentName = "calendar";
            popouts.currentCenter = Qt.binding(() => item.mapToItem(root, item.implicitWidth / 2, 0).x);
            popouts.hasCurrent = true;
        } else {
            popouts.hasCurrent = false;
        }
    }

    RowLayout {
        id: mainLayout

        anchors.fill: parent
        spacing: 2

        // Left side: macOS menu bar
        MacLeftMenus {
            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 12

            openMenu: root.openMenu
            screen: root.screen
            visibilities: root.visibilities

            onCloseRequested: root.openMenu = ""
            onOpenRequested: name => root.openMenu = name
        }

        // Center spacer
        WrappedLoader {
            id: spacer

            Layout.fillWidth: true
        }

        // Right side items
        WrappedLoader {
            id: tray

            sourceComponent: Tray {
                height: root.innerHeight
            }
        }
        WrappedLoader {
            id: statusIcons

            sourceComponent: StatusIcons {
                height: root.innerHeight
            }
        }
        MacIcon {
            Layout.alignment: Qt.AlignVCenter

            clickable: true
            color: Foundations.glass.barIcon
            name: "magnifier"
            size: 15

            onClicked: {
                if (root.visibilities.launcher)
                    root.visibilities.launcher = false;
                else {
                    root.openMenu = "";
                    root.visibilities.launcher = true;
                    root.visibilities.searchText = "";
                }
            }
        }
        WrappedLoader {
            id: date

            sourceComponent: Date {
                height: root.innerHeight

                onClicked: {
                    if (popouts.currentName === "calendar" && popouts.hasCurrent) {
                        popouts.hasCurrent = false;
                        popouts.currentName = "";
                    } else {
                        root.openMenu = "";
                        popouts.currentName = "calendar";
                        popouts.currentCenter = Qt.binding(() => date.mapToItem(root, date.width / 2, 0).x);
                        popouts.hasCurrent = true;
                    }
                }
            }
        }
        WrappedLoader {
            id: idleInhibitor

            sourceComponent: IdleInhibitor {
            }
        }
        WrappedLoader {
            id: notificationToggle

            Layout.rightMargin: 10

            sourceComponent: NotificationListToggle {
                visibilities: root.visibilities
            }
        }
    }

    Connections {
        function onLauncherChanged(): void {
            root.openMenu = "";
        }
        function onNotificationsChanged(): void {
            root.openMenu = "";
        }

        target: root.visibilities
    }

    component WrappedLoader: Loader {
        property string id

        Layout.alignment: Qt.AlignVCenter
        active: true
        visible: true
    }
}
