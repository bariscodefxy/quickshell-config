pragma ComponentBehavior: Bound

import qs.modules.popups as Popups
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    Item {
        id: dummyWrapper
    }

    Popups.Bluetooth {
        Layout.fillWidth: true
        wrapper: dummyWrapper
    }
}
