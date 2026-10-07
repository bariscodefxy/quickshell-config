pragma ComponentBehavior: Bound

import qs.ds
import Quickshell
import QtQuick
import qs.ds.animations
import qs.shell

BackgroundWrapper {
    id: root

    readonly property int contentHeight: 72
    readonly property int exclusiveZone: contentHeight + margin
    required property int margin
    required property var panels
    required property PersistentProperties visibilities
    required property ShellScreen screen

    hasCurrent: true

    readonly property Item pillItem: content.pillItem

    function closeMenu(): void {
        content.item?.closeMenu();
    }

    clip: false
    implicitHeight: contentHeight
    implicitWidth: content.implicitWidth
    visible: true

    Content {
        id: content

        panels: root.panels
        screen: root.screen
        visibilities: root.visibilities
        wrapper: root
    }
}
