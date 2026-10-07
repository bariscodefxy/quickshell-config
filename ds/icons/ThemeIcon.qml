pragma ComponentBehavior: Bound

import qs.ds
import Quickshell
import QtQuick
import QtQuick.Effects

// System icon-theme glyph, tinted to match the shell. Falls back to the
// bundled hand-drawn SVG when the theme lacks the name.
Item {
    id: root

    // Freedesktop icon name, e.g. "audio-volume-high-symbolic".
    property string name: ""
    // Bundled ds/icons/macos/*.svg name used when the theme lacks `name`.
    property string fallback: ""
    property color color: Foundations.glass.barIcon
    property real size: 16

    signal clicked()

    property bool clickable: false

    implicitHeight: size
    implicitWidth: size
    height: size
    width: size

    readonly property string themePath: {
        if (root.name === "" || typeof Quickshell.iconPath !== "function" || typeof Quickshell.hasThemeIcon !== "function")
            return "";
        // Gate on hasThemeIcon: an unchecked iconPath can return a broken
        // non-empty path (magenta checkers) when the theme lacks the name.
        if (!Quickshell.hasThemeIcon(root.name))
            return "";
        return Quickshell.iconPath(root.name);
    }
    readonly property bool useTheme: root.themePath !== ""

    Image {
        id: img

        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        mipmap: true
        source: root.useTheme ? root.themePath : (root.fallback !== "" ? Qt.resolvedUrl(`macos/${root.fallback}.svg`) : "")
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
