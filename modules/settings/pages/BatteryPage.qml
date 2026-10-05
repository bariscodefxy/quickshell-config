pragma ComponentBehavior: Bound

import qs.modules.popups as Popups
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    Popups.Battery {
        Layout.fillWidth: true
    }
}
