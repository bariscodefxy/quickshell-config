pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

// Persistent dock icon cache (~/.config/qsc/icon-cache.json).
// Engine reloads wipe QML state while DesktopEntries re-resolves in the
// background, so running apps briefly fall back to letter tiles. Live
// resolutions are stored per app key; on a miss the last-known URL is
// served instantly. Cached URLs are `image://icon/name` provider URLs,
// so they stay valid across theme switches (the provider resolves live).
Singleton {
    id: root

    readonly property string filePath: `${Quickshell.env("HOME")}/.config/qsc/icon-cache.json`

    property var cache: ({})

    function lookup(key: string): string {
        if (!key)
            return "";
        const hit = root.cache[key.toLowerCase()];
        if (hit && hit.src)
            return String(hit.src);
        return "";
    }

    function store(key: string, name: string, src: string): void {
        if (!key || !src)
            return;
        const k = key.toLowerCase();
        const hit = root.cache[k];
        if (hit && hit.src === src)
            return;
        const next = Object.assign({}, root.cache);
        next[k] = {
            name: name,
            src: src
        };
        root.cache = next;
    }

    function scheduleSave(): void {
        saveTimer.restart();
    }

    Component.onCompleted: {
        cacheFile.reload();
    }

    onCacheChanged: root.scheduleSave()

    Timer {
        id: saveTimer

        interval: 800
        repeat: false

        onTriggered: {
            cacheFile.writeAdapter();
        }
    }

    FileView {
        id: cacheFile

        path: root.filePath
        watchChanges: true

        JsonAdapter {
            property var cache: root.cache

            // Content-compared sync: the engine may hand a copy instead of
            // the shared reference, so identity (!==) alone still
            // ping-pongs adapter→root→adapter and flags a binding loop on
            // every store. Equal content settles silently.
            onCacheChanged: {
                if (JSON.stringify(root.cache ?? {}) !== JSON.stringify(cache ?? {}))
                    root.cache = cache ?? {};
            }
        }
    }
}
