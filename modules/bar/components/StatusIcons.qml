pragma ComponentBehavior: Bound

import qs.services
import qs.services as Services
import qs.ds
import qs.ds.text as Text
import qs.ds.icons
import qs.ds.buttons
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs.ds.animations

Rectangle {
    id: root

    property color colour: Foundations.glass.barIcon
    readonly property alias items: iconRow
    readonly property int margin: Foundations.spacing.s
    readonly property int iconSpacing: Foundations.spacing.xxs

    clip: true
    color: "transparent"
    implicitHeight: height
    implicitWidth: iconRow.implicitWidth + margin * 2
    radius: Foundations.radius.all

    Behavior on implicitWidth {
        BasicNumberAnimation {
            duration: Foundations.duration.slow
        }
    }

    RowLayout {
        id: iconRow

        anchors.centerIn: parent
        spacing: iconSpacing

        // Audio icon
        WrappedLoader {
            name: "audio"

            sourceComponent: RowLayout {
                spacing: iconSpacing

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    color: "#ff9500"
                    height: 8
                    radius: 4
                    visible: ScreenShare.isSharing
                    width: 8
                }

                MacIcon {
                    color: root.colour
                    name: "mic-off"
                    size: 15
                    visible: Audio.sourceMuted
                }

                MacIcon {
                    clickable: true
                    color: root.colour
                    name: Services.IconsService.getMacVolumeIcon(Audio.volume, Audio.muted)
                    size: 17

                    onClicked: {
                        Quickshell.execDetached(["pavucontrol"]);
                    }
                }
            }
        }

        // Keyboard layout icon
        WrappedLoader {
            name: "kblayout"

            sourceComponent: ClickableIcon {
                onClicked: {
                    const nextIndex = (Niri.currentKbLayoutIndex + 1) % Niri.kbLayouts.length;
                    Niri.switchKbLayout(nextIndex);
                }

                Text.BodyM {
                    color: root.colour
                    font.family: Foundations.font.family.mono
                    text: Niri.kbLayoutShortName(Niri.currentKbLayoutName())
                }
            }
        }

        // Network icon
        WrappedLoader {
            name: "network"

            sourceComponent: ClickableIcon {
                onClicked: Network.toggleWifi()

                MacIcon {
                    color: root.colour
                    name: Services.IconsService.getMacNetworkIcon(Network.active?.signalStrength ?? 0, Network.hasEthernetConnection, Network.active != null)
                    size: 17
                }
            }
        }

        // VPN icon
        WrappedLoader {
            name: "vpn"

            sourceComponent: ClickableIcon {
                onClicked: OpenVPN.toggle()

                Item {
                    id: vpnState

                    height: 16
                    width: 16

                    readonly property bool anyConnected: OpenVPN.connected || Tailscale.connected
                    readonly property bool anyConnecting: OpenVPN.connecting || Tailscale.connecting

                    MacIcon {
                        id: vpnIcon

                        anchors.centerIn: parent
                        color: {
                            if (!OpenVPN.available && !Tailscale.available)
                                return Foundations.palette.base08;
                            if (vpnState.anyConnecting)
                                return Foundations.palette.base0A;
                            if (vpnState.anyConnected)
                                return Foundations.palette.base0B;
                            return root.colour;
                        }
                        name: vpnState.anyConnecting ? "sync" : "key"
                        size: 15
                    }

                    // Subtle pulsing animation for connecting state
                    opacity: vpnPulse.running ? vpnPulse.value : 1.0

                    SequentialAnimation {
                        id: vpnPulse
                        running: vpnState.anyConnecting
                        loops: Animation.Infinite
                        property real value: 1.0
                        BasicNumberAnimation { target: vpnPulse; property: "value"; from: 1.0; to: 0.4; duration: Foundations.duration.slow }
                        BasicNumberAnimation { target: vpnPulse; property: "value"; from: 0.4; to: 1.0; duration: Foundations.duration.slow }
                    }

                    // Small progress dot indicator
                    Rectangle {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: -2
                        anchors.topMargin: -2
                        width: 6
                        height: 6
                        radius: 3
                        color: Foundations.palette.base0D
                        visible: vpnState.anyConnecting

                        SequentialAnimation on scale {
                            running: vpnState.anyConnecting
                            loops: Animation.Infinite
                            BasicNumberAnimation { from: 1.0; to: 1.4; duration: Foundations.duration.standard }
                            BasicNumberAnimation { from: 1.4; to: 1.0; duration: Foundations.duration.standard }
                        }
                    }
                }
            }
        }

        // Bluetooth section
        WrappedLoader {
            name: "bluetooth"

            sourceComponent: RowLayout {
                spacing: iconSpacing

                // Bluetooth icon (clickable to toggle)
                ClickableIcon {
                    onClicked: {
                        if (Bluetooth.defaultAdapter) {
                            Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                        }
                    }

                    MacIcon {
                        color: root.colour
                        name: Bluetooth.defaultAdapter?.enabled ? "bluetooth" : "bluetooth-off"
                        size: 15
                    }
                }

                // Connected bluetooth devices
                Repeater {
                    model: ScriptModel {
                        values: Bluetooth.devices.values.filter(d => d.state !== BluetoothDeviceState.Disconnected)
                    }

                    MacIcon {
                        id: device

                        required property BluetoothDevice modelData

                        color: root.colour
                        name: Services.IconsService.getMacBluetoothIcon(modelData.icon)
                        size: 15

                        SequentialAnimation on opacity {
                            alwaysRunToEnd: true
                            loops: Animation.Infinite
                            running: device.modelData.state !== BluetoothDeviceState.Connected

                            BasicNumberAnimation {
                                duration: Foundations.duration.slow
                                from: 1
                                to: 0
                            }
                            BasicNumberAnimation {
                                duration: Foundations.duration.slow
                                from: 0
                                to: 1
                            }
                        }
                    }
                }
            }
        }

        // Battery icon
        WrappedLoader {
            name: "battery"

            sourceComponent: ClickableIcon {
                onClicked: Quickshell.execDetached(["gnome-power-statistics"])

                Item {
                    height: 18
                    width: 27

                    MacBattery {
                        anchors.centerIn: parent
                        charging: !UPower.onBattery
                        color: root.colour
                        level: UPower.displayDevice.percentage
                        visible: UPower.displayDevice.isLaptopBattery
                    }

                    MaterialFontIcon {
                        id: profileIcon

                        anchors.centerIn: parent
                        animate: true
                        color: root.colour
                        text: {
                            if (PowerProfiles.profile === PowerProfile.PowerSaver)
                                return "energy_savings_leaf";
                            if (PowerProfiles.profile === PowerProfile.Performance)
                                return "rocket_launch";
                            return "balance";
                        }
                        visible: !UPower.displayDevice.isLaptopBattery
                    }
                }
            }
        }
    }

    component WrappedLoader: Loader {
        required property string name

        Layout.alignment: Qt.AlignVCenter
        // asynchronous: true
        visible: active
    }

    component ClickableIcon: Rectangle {
        id: clickableIcon

        signal clicked()

        default property alias content: contentContainer.children

        implicitWidth: contentContainer.childrenRect.width
        implicitHeight: contentContainer.childrenRect.height
        color: "transparent"
        radius: Foundations.radius.s

        Item {
            id: contentContainer
            anchors.centerIn: parent
            width: childrenRect.width
            height: childrenRect.height
        }

        InteractiveArea {
            function onClicked(): void {
                clickableIcon.clicked();
            }

            radius: clickableIcon.radius
        }
    }
}
