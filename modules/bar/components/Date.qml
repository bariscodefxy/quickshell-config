pragma ComponentBehavior: Bound

import qs.services
import qs.ds
import qs.ds.text as Text
import QtQuick

Rectangle {
    id: root

    signal clicked()

    property int margin: Foundations.spacing.s

    clip: true
    color: "transparent"
    implicitWidth: dateText.implicitWidth + margin * 2
    implicitHeight: height
    radius: Foundations.radius.all

    InteractiveArea {
        function onClicked(): void {
            root.clicked();
        }

        radius: parent.radius
    }

    Text.BodyS {
        id: dateText

        anchors.centerIn: parent
        color: Foundations.glass.barText
        font.family: Foundations.font.family.sans
        text: Time.format("ddd h:mm AP")
    }
}
