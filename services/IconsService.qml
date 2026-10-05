pragma Singleton

import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    function getBluetoothIcon(icon: string): string {
        if (icon.includes("headset") || icon.includes("headphones"))
            return "headphones";
        if (icon.includes("audio"))
            return "speaker";
        if (icon.includes("phone"))
            return "smartphone";
        if (icon.includes("mouse"))
            return "mouse";
        if (icon.includes("keyboard"))
            return "keyboard";
        return "bluetooth";
    }
    function getMacBluetoothIcon(icon: string): string {
        if (icon.includes("headset") || icon.includes("headphones"))
            return "headphones";
        if (icon.includes("audio"))
            return "volume-mute";
        if (icon.includes("phone"))
            return "smartphone";
        if (icon.includes("mouse"))
            return "mouse";
        if (icon.includes("keyboard"))
            return "keyboard";
        return "bluetooth";
    }
    function getMicVolumeIcon(volume: real, isMuted: bool): string {
        if (!isMuted && volume > 0)
            return "mic";
        return "mic_off";
    }
    function getNetworkIcon(strength: real): string {
        if (strength >= 0.8)
            return "signal_wifi_4_bar";
        if (strength >= 0.6)
            return "network_wifi_3_bar";
        if (strength >= 0.4)
            return "network_wifi_2_bar";
        if (strength >= 0.2)
            return "network_wifi_1_bar";
        return "signal_wifi_0_bar";
    }
    function getMacNetworkIcon(strength: real, hasEthernet: bool, connected: bool): string {
        if (hasEthernet)
            return "ethernet";
        if (!connected)
            return "wifi-off";
        if (strength >= 0.4)
            return "wifi";
        return "wifi-low";
    }
    function getNotifIcon(summary: string): string {
        summary = summary.toLowerCase();
        if (summary.includes("reboot"))
            return "restart_alt";
        if (summary.includes("recording"))
            return "screen_record";
        if (summary.includes("battery"))
            return "power";
        if (summary.includes("screenshot"))
            return "screenshot_monitor";
        if (summary.includes("welcome"))
            return "waving_hand";
        if (summary.includes("time") || summary.includes("a break"))
            return "schedule";
        if (summary.includes("installed"))
            return "download";
        if (summary.includes("update"))
            return "update";
        if (summary.includes("unable to"))
            return "deployed_code_alert";
        if (summary.includes("profile"))
            return "person";
        if (summary.includes("file"))
            return "folder_copy";
        if (summary.includes("critical"))
            return "release_alert";
        return "chat";
    }
    function getVolumeIcon(volume: real, isMuted: bool): string {
        if (isMuted)
            return "no_sound";
        if (volume >= 0.5)
            return "volume_up";
        if (volume > 0)
            return "volume_down";
        return "volume_mute";
    }
    function getMacVolumeIcon(volume: real, isMuted: bool): string {
        if (isMuted)
            return "volume-off";
        if (volume >= 0.5)
            return "volume-high";
        if (volume > 0)
            return "volume-low";
        return "volume-mute";
    }

    // Freedesktop theme names for the system icon theme (MacTahoe).
    function getThemeVolumeIcon(volume: real, isMuted: bool): string {
        if (isMuted || volume <= 0)
            return "audio-volume-muted-symbolic";
        if (volume >= 0.5)
            return "audio-volume-high-symbolic";
        return "audio-volume-medium-symbolic";
    }
    function getThemeNetworkIcon(strength: real, hasEthernet: bool, connected: bool): string {
        if (hasEthernet)
            return "network-wired-symbolic";
        if (!connected)
            return "network-wireless-offline-symbolic";
        if (strength >= 0.8)
            return "network-wireless-signal-excellent-symbolic";
        if (strength >= 0.55)
            return "network-wireless-signal-good-symbolic";
        if (strength >= 0.3)
            return "network-wireless-signal-ok-symbolic";
        if (strength > 0)
            return "network-wireless-signal-weak-symbolic";
        return "network-wireless-signal-none-symbolic";
    }
    function getThemeBluetoothIcon(icon: string): string {
        if (icon.includes("headset") || icon.includes("headphones"))
            return "audio-headphones-symbolic";
        if (icon.includes("audio"))
            return "audio-volume-muted-symbolic";
        if (icon.includes("phone"))
            return "phone-symbolic";
        if (icon.includes("mouse"))
            return "input-mouse-symbolic";
        if (icon.includes("keyboard"))
            return "input-keyboard-symbolic";
        return "bluetooth-active-symbolic";
    }
    function getThemeBatteryIcon(fraction: real, charging: bool): string {
        let base = "battery-000-symbolic";
        if (fraction >= 0.9)
            base = "battery-100-symbolic";
        else if (fraction >= 0.7)
            base = "battery-080-symbolic";
        else if (fraction >= 0.5)
            base = "battery-060-symbolic";
        else if (fraction >= 0.3)
            base = "battery-040-symbolic";
        else if (fraction >= 0.15)
            base = "battery-020-symbolic";
        if (charging)
            base = base.replace("-symbolic", "-charging-symbolic");
        return base;
    }
}
