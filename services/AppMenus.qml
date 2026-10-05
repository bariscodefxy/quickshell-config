pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

// Per-application menu content for the macOS-style menu bar.
//
// There is no Wayland protocol that exports a program's internal menubar
// (unlike macOS), so menus cannot be read from the focused app. Instead this
// maps the focused app-id to genuinely working actions for that app class.
// Descriptor: { label, shortcut?, separator?, kind, arg? }
// kind: "shell" (sh -c) | "spawn" (niri spawn, split on spaces, no ~)
//       | "niri" (named Niri action) | "dir" (~/subdir in file manager)
//       | "launcher" (open launcher with text) | "settings" | "quitapp"
Singleton {
    id: root

    function appClass(appId: string): string {
        const a = (appId || "").toLowerCase();
        if (!a)
            return "desktop";
        if (/chrom|firefox|brave|edge|vivaldi|opera|zen/.test(a))
            return "browser";
        if (/alacritty|foot|kitty|ghostty|wezterm|konsole|gnome-terminal|ptyxis/.test(a))
            return "terminal";
        if (/code|codium|cursor|zed|sublime|neovide|emacs/.test(a))
            return "editor";
        if (/thunar|dolphin|nautilus|nemo|pcmanfm|caja/.test(a))
            return "files";
        if (/discord|vesktop|telegram|slack|signal|whatsapp/.test(a))
            return "chat";
        if (/mpv|vlc|loupe|eog|imv|showtime|parole|celluloid/.test(a))
            return "media";
        return "generic";
    }

    function binaryOf(appId: string, fallback: string): string {
        const b = (appId || "").split(".").pop().toLowerCase();
        return b || fallback;
    }

    function fileItems(appId: string): var {
        const cls = root.appClass(appId);
        const bin = root.binaryOf(appId, "");

        if (cls === "browser") {
            const b = bin.includes("firefox") ? "firefox" : "chromium";
            const priv = bin.includes("firefox") ? "firefox --private-window about:blank" : "chromium --incognito about:blank";
            return [
                { label: "New Window", shortcut: "⌘N", kind: "spawn", arg: `${b} --new-window about:blank` },
                { label: "New Private Window", shortcut: "⇧⌘N", kind: "spawn", arg: priv },
                { separator: true },
                { label: "Close Window", shortcut: "⌘W", kind: "niri", arg: "closeFocusedWindow" }
            ];
        }
        if (cls === "terminal") {
            return [
                { label: "New Window", shortcut: "⌘N", kind: "spawn", arg: bin || "alacritty" },
                { separator: true },
                { label: "Close Window", shortcut: "⌘W", kind: "niri", arg: "closeFocusedWindow" }
            ];
        }
        if (cls === "editor") {
            const e = bin || "code";
            return [
                { label: "New Window", shortcut: "⇧⌘N", kind: "spawn", arg: `${e} -n` },
                { label: "Open Home Folder…", shortcut: "⌘O", kind: "shell", arg: `${e} -n ~` },
                { separator: true },
                { label: "Close Window", shortcut: "⌘W", kind: "niri", arg: "closeFocusedWindow" }
            ];
        }
        if (cls === "chat") {
            return [
                { label: "Show Downloads Folder", kind: "dir", arg: "Downloads" },
                { separator: true },
                { label: "Close Window", shortcut: "⌘W", kind: "niri", arg: "closeFocusedWindow" }
            ];
        }
        if (cls === "media") {
            return [
                { label: "Open Videos Folder", shortcut: "⌘O", kind: "dir", arg: "Videos" },
                { separator: true },
                { label: "Close Window", shortcut: "⌘W", kind: "niri", arg: "closeFocusedWindow" }
            ];
        }
        // files, desktop, generic: file-manager actions.
        return [
            { label: "New Finder Window", shortcut: "⌘N", kind: "shell", arg: "thunar ~" },
            { label: "New Folder", shortcut: "⇧⌘N", kind: "shell", arg: "mkdir -p ~/'Untitled Folder' && thunar ~" },
            { label: "Open…", shortcut: "⌘O", kind: "shell", arg: "thunar ~" },
            { separator: true },
            { label: "Close Window", shortcut: "⌘W", kind: "niri", arg: "closeFocusedWindow" }
        ];
    }

    function goItems(appId: string): var {
        if (root.appClass(appId) === "browser") {
            return [
                { label: "History", shortcut: "⌘Y", kind: "spawn", arg: "chromium chrome://history" },
                { label: "Downloads", kind: "spawn", arg: "chromium chrome://downloads" },
                { label: "Bookmarks", shortcut: "⌥⌘B", kind: "spawn", arg: "chromium chrome://bookmarks" },
                { label: "Extensions", kind: "spawn", arg: "chromium chrome://extensions" }
            ];
        }
        return [
            { label: "Home", shortcut: "⇧⌘H", kind: "dir", arg: "" },
            { label: "Documents", kind: "dir", arg: "Documents" },
            { label: "Downloads", kind: "dir", arg: "Downloads" },
            { label: "Music", kind: "dir", arg: "Music" },
            { label: "Pictures", kind: "dir", arg: "Pictures" }
        ];
    }
}
