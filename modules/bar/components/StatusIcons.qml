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

    signal popoutRequested(string name, var anchor)

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
            active: Settings.showAudio
            name: "audio"
            visible: Settings.showAudio

            sourceComponent: RowLayout {
                id: audioRow

                spacing: iconSpacing

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    color: "#ff9500"
                    height: 8
                    radius: 4
                    visible: ScreenShare.isSharing
                    width: 8
                }

                ThemeIcon {
                    color: root.colour
                    fallback: "mic-off"
                    name: "audio-input-microphone-muted-symbolic"
                    size: 15
                    visible: Audio.sourceMuted
                }

                ThemeIcon {
                    clickable: true
                    color: root.colour
                    fallback: Services.IconsService.getMacVolumeIcon(Audio.volume, Audio.muted)
                    name: Services.IconsService.getThemeVolumeIcon(Audio.volume, Audio.muted)
                    size: 17

                    onClicked: {
                        root.popoutRequested("audio", audioRow);
                    }
                }
            }
        }

        // Keyboard layout icon
        WrappedLoader {
            active: Settings.showKbLayout
            name: "kblayout"
            visible: Settings.showKbLayout

            sourceComponent: ClickableIcon {
                id: kbClick

                onClicked: {
                    root.popoutRequested("kblayout", kbClick);
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
            active: Settings.showNetwork
            name: "network"
            visible: Settings.showNetwork

            sourceComponent: ClickableIcon {
                id: netClick

                onClicked: {
                    root.popoutRequested("network", netClick);
                }

                ThemeIcon {
                    color: root.colour
                    fallback: Services.IconsService.getMacNetworkIcon(Network.active?.signalStrength ?? 0, Network.hasEthernetConnection, Network.active != null)
                    name: Services.IconsService.getThemeNetworkIcon(Network.active?.signalStrength ?? 0, Network.hasEthernetConnection, Network.active != null)
                    size: 17
                }
            }
        }

        // VPN icon
        WrappedLoader {
            active: Settings.showVpn
            name: "vpn"
            visible: Settings.showVpn

            sourceComponent: ClickableIcon {
                id: vpnClick

                onClicked: {
                    root.popoutRequested("vpn", vpnClick);
                }

                Item {
                    id: vpnState

                    height: 16
                    width: 16

                    readonly property bool anyConnected: OpenVPN.connected || Tailscale.connected
                    readonly property bool anyConnecting: OpenVPN.connecting || Tailscale.connecting

                    ThemeIcon {
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
                        fallback: vpnState.anyConnecting ? "sync" : "key"
                        name: "network-vpn-symbolic"
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
            active: Settings.showBluetooth
            name: "bluetooth"
            visible: Settings.showBluetooth

            sourceComponent: RowLayout {
                spacing: iconSpacing

                // Bluetooth icon (clickable to toggle)
                ClickableIcon {
                    id: btClick

                    onClicked: {
                        root.popoutRequested("bluetooth", btClick);
                    }

                    ThemeIcon {
                        color: root.colour
                        fallback: Bluetooth.defaultAdapter?.enabled ? "bluetooth" : "bluetooth-off"
                        name: Bluetooth.defaultAdapter?.enabled ? "bluetooth-active-symbolic" : "bluetooth-disabled-symbolic"
                        size: 15
                    }
                }

                // Connected bluetooth devices
                Repeater {
                    model: ScriptModel {
                        values: Bluetooth.devices.values.filter(d => d.state !== BluetoothDeviceState.Disconnected)
                    }

                    ThemeIcon {
                        id: device

                        required property BluetoothDevice modelData

                        color: root.colour
                        fallback: Services.IconsService.getMacBluetoothIcon(modelData.icon)
                        name: Services.IconsService.getThemeBluetoothIcon(modelData.icon)
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
            active: Settings.showBattery
            name: "battery"
            visible: Settings.showBattery

            sourceComponent: ClickableIcon {
                id: battClick

                onClicked: {
                    root.popoutRequested("battery", battClick);
                }

                Item {
                    height: 18
                    width: 27

                    ThemeIcon {
                        anchors.centerIn: parent
                        color: root.colour
                        fallback: ""
                        name: Services.IconsService.getThemeBatteryIcon(UPower.displayDevice.percentage, !UPower.onBattery)
                        size: 19
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
