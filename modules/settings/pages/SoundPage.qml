pragma ComponentBehavior: Bound

import qs.modules.popups as Popups
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    Item {
        id: dummyWrapper
    }

    Popups.Audio {
        Layout.fillWidth: true
        wrapper: dummyWrapper
    }
}
