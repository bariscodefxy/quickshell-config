pragma ComponentBehavior: Bound

import qs.modules.popups as Popups
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    QtObject {
        id: dummyWrapper

        property bool needsFocus: false
    }

    Popups.Network {
        Layout.fillWidth: true
        wrapper: dummyWrapper
    }
}
