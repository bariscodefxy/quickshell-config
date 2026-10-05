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

    // Open menu geometry in window coordinates, for the shell input mask.
    readonly property rect menuGeo: leftMenus.menuGeo

    function closeMenus(): void {
        root.openMenu = "";
    }

    function closePopout(): void {
        popouts.hasCurrent = false;
        popouts.currentName = "";
    }

    function togglePopout(name: string, anchor: Item): void {
        if (popouts.currentName === name && popouts.hasCurrent) {
            root.closePopout();
        } else {
            root.openMenu = "";
            popouts.currentName = name;
            popouts.currentCenter = Qt.binding(() => anchor.mapToItem(root, anchor.width / 2, 0).x);
            popouts.hasCurrent = true;
        }
    }

    RowLayout {
        id: mainLayout

        anchors.fill: parent
        spacing: 2

        // Left side: macOS menu bar
        MacLeftMenus {
            id: leftMenus

            Layout.alignment: Qt.AlignVCenter
            Layout.leftMargin: 12

            openMenu: root.openMenu
            screen: root.screen
            visibilities: root.visibilities
            windowRef: root

            onCloseRequested: root.openMenu = ""
            onOpenRequested: name => {
                root.openMenu = name;
                root.closePopout();
            }
        }

        // Center spacer
        WrappedLoader {
            Layout.fillWidth: true
        }

        // Right side items
        WrappedLoader {
            active: Settings.showTray
            visible: Settings.showTray

            sourceComponent: Tray {
                height: root.innerHeight

                onMenuRequested: (index, anchor) => root.togglePopout(`traymenu${index}`, anchor)
            }
        }
        WrappedLoader {
            sourceComponent: StatusIcons {
                height: root.innerHeight

                onPopoutRequested: (name, anchor) => root.togglePopout(name, anchor)
            }
        }
        MacIcon {
            Layout.alignment: Qt.AlignVCenter

            clickable: true
            color: Foundations.glass.barIcon
            name: "magnifier"
            size: 15
            visible: Settings.showSpotlight

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

            active: Settings.showDate
            visible: Settings.showDate

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
            sourceComponent: IdleInhibitor {
            }
        }
        WrappedLoader {
            Layout.rightMargin: 10

            sourceComponent: NotificationListToggle {
                visibilities: root.visibilities
            }
        }
    }

    Connections {
        function onLauncherChanged(): void {
            root.openMenu = "";
            root.closePopout();
        }
        function onNotificationsChanged(): void {
            root.openMenu = "";
            root.closePopout();
        }

        target: root.visibilities
    }

    component WrappedLoader: Loader {
        Layout.alignment: Qt.AlignVCenter
        active: true
        visible: true
    }
}
