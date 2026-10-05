pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int currentKbLayoutIndex: 0
    readonly property string focusedOutput: workspaces[focusedWorkspaceIndex]?.output ?? ""
    property int focusedWorkspaceIndex: 0
    property bool inOverview: false
    property list<string> kbLayouts: []
    property list<var> workspaces: []

    // Function to get current layout name
    function currentKbLayoutName(): string {
        if (root.currentKbLayoutIndex >= 0 && root.currentKbLayoutIndex < root.kbLayouts.length) {
            return root.kbLayouts[root.currentKbLayoutIndex];
        }
        return "";
    }

    // Map an xkb layout description (as reported by `niri msg keyboard-layouts`,
    // e.g. "Turkish", "English (US)", "German (Neo)") to a 2-letter display code.
    // Falls back to the first two latin letters, "??" when nothing usable found.
    function kbLayoutShortName(fullName: string): string {
        if (!fullName)
            return "??";

        const n = fullName.trim().toLowerCase();

        // Already a short xkb code ("tr", "us", "ara", ...): normalize to 2 letters.
        if (/^[a-z]{2,3}$/.test(n)) {
            const codeAliases = {
                "ara": "ar",
                "bra": "pt",
                "cz": "cs",
                "gb": "en",
                "gr": "el",
                "jp": "ja",
                "kr": "ko",
                "us": "en"
            };
            if (n in codeAliases)
                return codeAliases[n];
            return n.length === 3 ? n.slice(0, 2) : n;
        }

        // Language description -> ISO 639-1. Ordered so specific variants match first.
        const table = [
            ["turkish", "tr"],
            ["english", "en"],
            ["spanish", "es"],
            ["german", "de"],
            ["deutsch", "de"],
            ["french", "fr"],
            ["italian", "it"],
            ["portuguese", "pt"],
            ["brazilian", "pt"],
            ["russian", "ru"],
            ["ukrainian", "uk"],
            ["belarusian", "be"],
            ["polish", "pl"],
            ["czech", "cs"],
            ["slovak", "sk"],
            ["dutch", "nl"],
            ["swedish", "sv"],
            ["norwegian", "no"],
            ["danish", "da"],
            ["finnish", "fi"],
            ["hungarian", "hu"],
            ["romanian", "ro"],
            ["bulgarian", "bg"],
            ["greek", "el"],
            ["hebrew", "he"],
            ["arabic", "ar"],
            ["persian", "fa"],
            ["farsi", "fa"],
            ["thai", "th"],
            ["chinese", "zh"],
            ["japanese", "ja"],
            ["korean", "ko"],
            ["croatian", "hr"],
            ["serbian", "sr"],
            ["slovenian", "sl"],
            ["bosnian", "bs"],
            ["albanian", "sq"],
            ["lithuanian", "lt"],
            ["latvian", "lv"],
            ["estonian", "et"],
            ["icelandic", "is"],
            ["irish", "ga"],
            ["maltese", "mt"],
            ["georgian", "ka"],
            ["armenian", "hy"],
            ["azerbaijani", "az"],
            ["kazakh", "kk"],
            ["uzbek", "uz"],
            ["vietnamese", "vi"],
            ["hindi", "hi"],
            ["bengali", "bn"],
            ["tamil", "ta"],
            ["nepali", "ne"],
            ["indonesian", "id"],
            ["malay", "ms"],
            ["swiss", "de"],
            ["belgian", "nl"],
            ["canadian", "en"],
            ["australian", "en"]
        ];
        for (let i = 0; i < table.length; i++) {
            if (n.includes(table[i][0]))
                return table[i][1];
        }

        // Parenthesized xkb code, e.g. "English (US)" without table hit.
        const paren = n.match(/\(([a-z]{2,3})\)/);
        if (paren)
            return root.kbLayoutShortName(paren[1]);

        const m = fullName.match(/[A-Za-z]{2,}/);
        return m ? m[0].slice(0, 2).toLowerCase() : "??";
    }

    function getWindowByAppId(appId: string, callback: var, titleHint: string): void {
        const hint = titleHint || "";
        getWindowIdProcess.running = false;
        getWindowIdProcess.targetAppId = appId.toLowerCase();
        getWindowIdProcess.titleHint = hint.toLowerCase();
        getWindowIdProcess.resultCallback = callback;
        getWindowIdProcess.running = true;
    }

    function focusWindowById(windowId: int): void {
        focusWindowProcess.command = ["niri", "msg", "action", "focus-window", "--id", windowId.toString()];
        focusWindowProcess.running = false;
        focusWindowProcess.running = true;
    }

    function closeAppWindows(appId: string): void {
        closeAppTimer.stop();
        const lower = appId.toLowerCase();
        closeAppProcess.targetAppId = lower;
        closeAppProcess.queue = [];
        closeAppProcess.phase = 0;
        closeAppProcess.running = false;
        closeAppProcess.running = true;
    }

    function spawn(command: string): void {
        spawnProcess.command = ["niri", "msg", "action", "spawn", "--"].concat(command.split(" "));
        spawnProcess.running = false;
        spawnProcess.running = true;
    }

    function switchKbLayout(index: int): void {
        switchLayoutProcess.command = ["niri", "msg", "action", "switch-layout", index.toString()];
        switchLayoutProcess.running = false;
        switchLayoutProcess.running = true;
    }

    function focusWorkspace(workspaceId: int): void {
        focusWorkspaceProcess.command = ["niri", "msg", "action", "focus-workspace", workspaceId.toString()];
        focusWorkspaceProcess.running = false;
        focusWorkspaceProcess.running = true;
    }

    function moveWindowToWorkspace(workspaceIdx: int): void {
        moveWindowProcess.command = ["niri", "msg", "action", "move-window-to-workspace", "--focus", "false", workspaceIdx.toString()];
        moveWindowProcess.running = false;
        moveWindowProcess.running = true;
    }

    function closeFocusedWindow(): void {
        closeWindowProcess.command = ["niri", "msg", "action", "close-window"];
        closeWindowProcess.running = false;
        closeWindowProcess.running = true;
    }

    function toggleFullscreen(): void {
        fullscreenProcess.command = ["niri", "msg", "action", "fullscreen-window"];
        fullscreenProcess.running = false;
        fullscreenProcess.running = true;
    }

    function toggleOverview(): void {
        overviewProcess.command = ["niri", "msg", "action", "toggle-overview"];
        overviewProcess.running = false;
        overviewProcess.running = true;
    }

    function openOverview(): void {
        openOverviewProcess.command = ["niri", "msg", "action", "open-overview"];
        openOverviewProcess.running = false;
        openOverviewProcess.running = true;
    }

    function focusNextWindow(): void {
        focusNextProcess.command = ["niri", "msg", "action", "focus-window-down"];
        focusNextProcess.running = false;
        focusNextProcess.running = true;
    }

    function focusPrevWindow(): void {
        focusPrevProcess.command = ["niri", "msg", "action", "focus-window-up"];
        focusPrevProcess.running = false;
        focusPrevProcess.running = true;
    }

    function maximizeColumn(): void {
        maximizeProcess.command = ["niri", "msg", "action", "maximize-column"];
        maximizeProcess.running = false;
        maximizeProcess.running = true;
    }

    function toggleFloating(): void {
        floatingProcess.command = ["niri", "msg", "action", "toggle-window-floating"];
        floatingProcess.running = false;
        floatingProcess.running = true;
    }

    function showHotkeyOverlay(): void {
        hotkeyProcess.command = ["niri", "msg", "action", "show-hotkey-overlay"];
        hotkeyProcess.running = false;
        hotkeyProcess.running = true;
    }

    function quitCompositor(): void {
        quitProcess.command = ["niri", "msg", "action", "quit", "--skip-confirmation"];
        quitProcess.running = false;
        quitProcess.running = true;
    }

    Component.onCompleted: {
        layoutsInitProcess.running = true;
    }

    Process {
        command: ["niri", "msg", "-j", "event-stream"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const event = JSON.parse(data.trim());

                if (event.WorkspacesChanged) {
                    root.workspaces = [...event.WorkspacesChanged.workspaces].sort((a, b) => a.idx - b.idx);
                    root.focusedWorkspaceIndex = root.workspaces.findIndex(w => w.is_focused);
                    if (root.focusedWorkspaceIndex < 0) {
                        root.focusedWorkspaceIndex = 0;
                    }
                } else if (event.WorkspaceActivated) {
                    root.focusedWorkspaceIndex = root.workspaces.findIndex(w => w.id === event.WorkspaceActivated.id);
                    if (root.focusedWorkspaceIndex < 0) {
                        root.focusedWorkspaceIndex = 0;
                    }
                } else if (event.OverviewOpenedOrClosed) {
                    root.inOverview = event.OverviewOpenedOrClosed.is_open;
                } else if (event.KeyboardLayoutsChanged) {
                    root.kbLayouts = [];
                    root.currentKbLayoutIndex = -1;

                    const layouts = event.KeyboardLayoutsChanged.keyboard_layouts;
                    if (layouts && layouts.names) {
                        root.kbLayouts = layouts.names;
                        root.currentKbLayoutIndex = layouts.current_idx || 0;
                    }
                } else if (event.KeyboardLayoutSwitched) {
                    root.currentKbLayoutIndex = event.KeyboardLayoutSwitched.idx;
                }
            }
        }
    }

    Process {
        id: switchLayoutProcess

        running: false
    }

    Process {
        id: focusWorkspaceProcess

        running: false
    }

    Process {
        id: moveWindowProcess

        running: false
    }

    Process {
        id: layoutsInitProcess

        command: ["niri", "msg", "-j", "keyboard-layouts"]
        running: false

        onStdoutChanged: {
            try {
                const data = JSON.parse(stdout.trim());
                if (data.names) {
                    root.kbLayouts = data.names;
                    root.currentKbLayoutIndex = data.current_idx || 0;
                }
            } catch (e) {
                console.log("Error parsing keyboard layouts:", e);
            }
        }
    }
    Process {
        id: spawnProcess

        running: false
    }

    Process {
        id: getWindowIdProcess

        property string targetAppId
        property string titleHint
        property var resultCallback

        command: ["niri", "msg", "-j", "windows"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const windows = JSON.parse(text.trim());
                    const knownBrowsers = ["chromium-browser", "chromium", "google-chrome", "google-chrome-stable", "firefox", "firefox-esr"];
                    const isBrowser = knownBrowsers.includes(getWindowIdProcess.targetAppId);

                    // Strategy 1: For browser notifications with titleHint,
                    // try to find the specific PWA window first.
                    if (isBrowser && getWindowIdProcess.titleHint && getWindowIdProcess.titleHint.length > 0) {
                        const hint = getWindowIdProcess.titleHint;

                        for (let i = 0; i < windows.length; i++) {
                            const window = windows[i];
                            const windowAppId = (window.app_id || "").toLowerCase();
                            if (windowAppId.startsWith("chrome-") && windowAppId.includes(hint)) {
                                getWindowIdProcess.resultCallback(window);
                                return;
                            }
                        }

                        const hintWords = hint.split(/\s+/).filter(w => w.length > 2);
                        for (let i = 0; i < windows.length; i++) {
                            const window = windows[i];
                            const windowAppId = (window.app_id || "").toLowerCase();
                            if (windowAppId.startsWith("chrome-") && windowAppId !== getWindowIdProcess.targetAppId) {
                                const matches = hintWords.filter(w => windowAppId.includes(w)).length;
                                if (matches > 0) {
                                    getWindowIdProcess.resultCallback(window);
                                    return;
                                }
                            }
                        }

                        // Check window titles for appName
                        for (let i = 0; i < windows.length; i++) {
                            const window = windows[i];
                            const windowTitle = (window.title || "").toLowerCase();
                            if (windowTitle.includes(getWindowIdProcess.titleHint)) {
                                getWindowIdProcess.resultCallback(window);
                                return;
                            }
                        }
                    }

                    // Strategy 2: Exact app_id match
                    for (let i = 0; i < windows.length; i++) {
                        const window = windows[i];
                        const windowAppId = (window.app_id || "").toLowerCase();
                        if (windowAppId === getWindowIdProcess.targetAppId) {
                            getWindowIdProcess.resultCallback(window);
                            return;
                        }
                    }

                    // Strategy 3: Title-based fallback for non-browser apps
                    if (getWindowIdProcess.titleHint && getWindowIdProcess.titleHint.length > 0) {
                        for (let i = 0; i < windows.length; i++) {
                            const window = windows[i];
                            const windowTitle = (window.title || "").toLowerCase();
                            if (windowTitle.includes(getWindowIdProcess.titleHint)) {
                                getWindowIdProcess.resultCallback(window);
                                return;
                            }
                        }
                    }

                    getWindowIdProcess.resultCallback(null);
                } catch (e) {
                    console.log("Error parsing windows JSON:", e);
                    getWindowIdProcess.resultCallback(null);
                }
            }
        }
    }

    Process {
        id: focusWindowProcess

        running: false
    }

    Process {
        id: closeAppProcess

        property string targetAppId: ""
        property var queue: []
        property int phase: 0

        running: false
        command: ["niri", "msg", "-j", "windows"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const windows = JSON.parse(text.trim());
                    const ids = [];
                    for (let i = 0; i < windows.length; i++) {
                        if ((windows[i].app_id || "").toLowerCase() === closeAppProcess.targetAppId)
                            ids.push(windows[i].id);
                    }
                    closeAppProcess.queue = ids;
                    closeAppProcess.phase = 0;
                    closeAppTimer.start();
                } catch (e) {
                    console.log("Error parsing windows JSON for close-app:", e);
                }
            }
        }
    }

    Timer {
        id: closeAppTimer

        interval: 220
        repeat: true

        onTriggered: {
            if (closeAppProcess.queue.length === 0) {
                closeAppTimer.stop();
                return;
            }
            if (closeAppProcess.phase === 0) {
                root.focusWindowById(closeAppProcess.queue[0]);
                closeAppProcess.phase = 1;
            } else {
                root.closeFocusedWindow();
                closeAppProcess.queue = closeAppProcess.queue.slice(1);
                closeAppProcess.phase = 0;
            }
        }
    }

    Process {
        id: closeWindowProcess

        running: false
    }

    Process {
        id: fullscreenProcess

        running: false
    }

    Process {
        id: overviewProcess

        running: false
    }

    Process {
        id: openOverviewProcess

        running: false
    }

    Process {
        id: focusNextProcess

        running: false
    }

    Process {
        id: focusPrevProcess

        running: false
    }

    Process {
        id: maximizeProcess

        running: false
    }

    Process {
        id: floatingProcess

        running: false
    }

    Process {
        id: hotkeyProcess

        running: false
    }

    Process {
        id: quitProcess

        running: false
    }
}
