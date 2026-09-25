// Hyprland shortcut cheatsheet overlay.
//
// Data comes from `hyprctl binds -j`, never from parsing the Lua config. That
// matters here: the config generates 30 workspace binds from a `for` loop that
// no text parser can expand, and because the config is Lua every bind reports
// dispatcher "__lua" with an opaque arg - so the `description` field is the only
// human-readable label that exists. Binds without one are counted, not shown.
//
// Toggled over IPC:  qs -c hypr-cheatsheet ipc call cheatsheet toggle

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

ShellRoot {
    id: root

    property bool shown: false
    property var groups: []
    property int unlabelled: 0
    property string filter: ""

    // Catppuccin Mocha
    readonly property color cBase: "#1e1e2e"
    readonly property color cMantle: "#181825"
    readonly property color cSurface0: "#313244"
    readonly property color cSurface1: "#45475a"
    readonly property color cText: "#cdd6f4"
    readonly property color cSubtext: "#a6adc8"
    readonly property color cOverlay: "#6c7086"
    readonly property color cBlue: "#89b4fa"
    readonly property color cSapphire: "#74c7ec"

    IpcHandler {
        target: "cheatsheet"

        function toggle(): string {
            if (root.shown) {
                root.shown = false;
                return "CLOSED";
            }
            root.reload();
            root.shown = true;
            return "OPENED";
        }

        function open(): string {
            root.reload();
            root.shown = true;
            return "OPENED";
        }

        function close(): string {
            root.shown = false;
            return "CLOSED";
        }
    }

    // Re-read on every open so the sheet never goes stale after a config reload.
    function reload() {
        root.filter = "";
        bindsProc.running = true;
    }

    Process {
        id: bindsProc
        command: ["hyprctl", "binds", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.ingest(text)
        }
        onExited: code => {
            if (code !== 0)
                console.warn("hyprctl binds failed, exit", code);
        }
    }

    // ---------------------------------------------------------------- parsing

    readonly property var modBits: [
        { bit: 64, name: "SUPER" },
        { bit: 4, name: "CTRL" },
        { bit: 8, name: "ALT" },
        { bit: 1, name: "SHIFT" }
    ]

    readonly property var keyNames: ({
        "RETURN": "Enter",
        "SLASH": "/",
        "BRACKETLEFT": "[",
        "BRACKETRIGHT": "]",
        "COMMA": ",",
        "PERIOD": ".",
        "SEMICOLON": ";",
        "Print": "PrtSc",
        "Escape": "Esc",
        "mouse_up": "Scroll Up",
        "mouse_down": "Scroll Down",
        "mouse:272": "Left Click",
        "mouse:273": "Right Click",
        "XF86AudioRaiseVolume": "Vol +",
        "XF86AudioLowerVolume": "Vol −",
        "XF86AudioMute": "Mute",
        "XF86AudioMicMute": "Mic Mute",
        "XF86AudioNext": "Next",
        "XF86AudioPrev": "Prev",
        "XF86AudioPlay": "Play",
        "XF86AudioPause": "Pause",
        "XF86MonBrightnessUp": "Bright +",
        "XF86MonBrightnessDown": "Bright −"
    })

    // Ordered - first match wins, so "Move window to workspace 3" lands in
    // Workspaces rather than Window.
    readonly property var rules: [
        { re: /screenshot|pick colour/i, group: "Screenshot" },
        { re: /monitor/i, group: "Monitors" },
        { re: /workspace|scratchpad|email/i, group: "Workspaces" },
        { re: /^group/i, group: "Groups" },
        { re: /resize|shrink|grow|drag/i, group: "Resize" },
        { re: /^(focus|swap|cycle)/i, group: "Focus & Swap" },
        { re: /terminal|file manager|browser|system monitor|audio mixer|dictation/i, group: "Applications" },
        { re: /launcher|clipboard|notification|power menu|lock|shortcuts/i, group: "Shell" },
        { re: /volume|mute|track|play|pause|bright/i, group: "Media" }
    ]

    function prettyKey(k) {
        return keyNames[k] !== undefined ? keyNames[k] : k;
    }

    function chord(b) {
        const parts = [];
        for (let i = 0; i < modBits.length; i++)
            if (b.modmask & modBits[i].bit)
                parts.push(modBits[i].name);
        parts.push(prettyKey(b.key));
        return parts;
    }

    function groupFor(desc) {
        for (let i = 0; i < rules.length; i++)
            if (rules[i].re.test(desc))
                return rules[i].group;
        return "Window";
    }

    function ingest(text) {
        let data;
        try {
            data = JSON.parse(text);
        } catch (e) {
            console.warn("failed to parse hyprctl binds:", e);
            return;
        }

        const buckets = {};
        let skipped = 0;

        for (let i = 0; i < data.length; i++) {
            const b = data[i];
            const desc = (b.description || "").trim();
            if (desc === "") {
                skipped++;
                continue;
            }

            // Submap binds belong to a mode, not the global sheet.
            const g = b.submap && b.submap !== "" ? "Mode: " + b.submap : groupFor(desc);
            if (!buckets[g])
                buckets[g] = [];
            buckets[g].push({
                keys: chord(b),
                desc: desc,
                repeats: b["repeat"] === true,
                locked: b.locked === true
            });
        }

        // Stable, hand-picked ordering; anything unexpected sorts to the end.
        const order = ["Applications", "Shell", "Window", "Focus & Swap", "Workspaces",
                       "Monitors", "Groups", "Resize", "Screenshot", "Media"];
        const names = Object.keys(buckets).sort((a, b) => {
            const ia = order.indexOf(a), ib = order.indexOf(b);
            return (ia === -1 ? 99 : ia) - (ib === -1 ? 99 : ib) || a.localeCompare(b);
        });

        const out = [];
        for (let i = 0; i < names.length; i++)
            out.push({ name: names[i], items: buckets[names[i]] });

        root.unlabelled = skipped;
        root.groups = out;
    }

    // Filter applied at render time so typing never re-runs hyprctl.
    function visibleGroups() {
        const q = root.filter.toLowerCase().trim();
        if (q === "")
            return root.groups;
        const out = [];
        for (let i = 0; i < root.groups.length; i++) {
            const g = root.groups[i];
            const kept = g.items.filter(it =>
                it.desc.toLowerCase().indexOf(q) !== -1
                || it.keys.join(" ").toLowerCase().indexOf(q) !== -1);
            if (kept.length > 0)
                out.push({ name: g.name, items: kept });
        }
        return out;
    }

    // Split groups across two columns, balancing by row count rather than by
    // group count so one huge group doesn't leave a column stranded.
    function splitColumns(gs) {
        let total = 0;
        for (let i = 0; i < gs.length; i++)
            total += gs[i].items.length + 2;
        const left = [], right = [];
        let acc = 0;
        for (let i = 0; i < gs.length; i++) {
            if (acc < total / 2) {
                left.push(gs[i]);
                acc += gs[i].items.length + 2;
            } else {
                right.push(gs[i]);
            }
        }
        return [left, right];
    }

    // ------------------------------------------------------------------- view

    PanelWindow {
        id: win
        visible: root.shown

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "hypr-cheatsheet"
        WlrLayershell.keyboardFocus: root.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        WlrLayershell.exclusiveZone: 0

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"

        // Scrim. Click anywhere outside the card to dismiss.
        Rectangle {
            anchors.fill: parent
            color: "#cc11111b"

            MouseArea {
                anchors.fill: parent
                onClicked: root.shown = false
            }
        }

        FocusScope {
            anchors.fill: parent
            focus: root.shown

            Keys.onEscapePressed: root.shown = false

            Rectangle {
                id: card
                anchors.centerIn: parent
                width: Math.min(parent.width - 80, 1180)
                // Deliberately NOT derived from the content's implicitHeight:
                // contentCol fills this Rectangle, so sizing the Rectangle from
                // its content is a polish() loop. The list scrolls instead.
                height: Math.min(parent.height - 80, 860)
                radius: 14
                color: root.cBase
                border.width: 1
                border.color: root.cSurface1

                // Swallow clicks so they don't reach the dismiss scrim.
                MouseArea {
                    anchors.fill: parent
                }

                Column {
                    id: contentCol
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    // Header
                    Item {
                        width: parent.width
                        height: 34

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Keyboard Shortcuts"
                            color: root.cText
                            font.pixelSize: 20
                            font.bold: true
                        }

                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            width: 280
                            height: 30
                            radius: 8
                            color: root.cMantle
                            border.width: 1
                            border.color: searchInput.activeFocus ? root.cBlue : root.cSurface0

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Type to filter…"
                                color: root.cOverlay
                                font.pixelSize: 12
                                visible: searchInput.text === ""
                            }

                            TextInput {
                                id: searchInput
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                verticalAlignment: TextInput.AlignVCenter
                                color: root.cText
                                font.pixelSize: 12
                                clip: true
                                focus: root.shown
                                onTextChanged: root.filter = text
                                Keys.onEscapePressed: root.shown = false
                            }
                        }
                    }

                    // Body
                    Flickable {
                        width: parent.width
                        height: parent.height - 34 - 20 - 32
                        contentWidth: width
                        contentHeight: columnsRow.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        Row {
                            id: columnsRow
                            width: parent.width
                            spacing: 28

                            readonly property var cols: root.splitColumns(root.visibleGroups())

                            Repeater {
                                model: 2

                                Column {
                                    required property int index
                                    width: (columnsRow.width - 28) / 2
                                    spacing: 14

                                    Repeater {
                                        model: columnsRow.cols[parent.index]

                                        Column {
                                            required property var modelData
                                            width: parent.width
                                            spacing: 4

                                            Text {
                                                text: modelData.name
                                                color: root.cSapphire
                                                font.pixelSize: 12
                                                font.bold: true
                                                font.capitalization: Font.AllUppercase
                                                bottomPadding: 2
                                            }

                                            Repeater {
                                                model: modelData.items

                                                Item {
                                                    required property var modelData
                                                    width: parent.width
                                                    height: 24

                                                    Row {
                                                        id: keyRow
                                                        anchors.left: parent.left
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        spacing: 3

                                                        Repeater {
                                                            model: modelData.keys

                                                            Rectangle {
                                                                required property var modelData
                                                                width: kt.implicitWidth + 12
                                                                height: 19
                                                                radius: 4
                                                                color: root.cSurface0
                                                                border.width: 1
                                                                border.color: root.cSurface1

                                                                Text {
                                                                    id: kt
                                                                    anchors.centerIn: parent
                                                                    text: modelData
                                                                    color: root.cText
                                                                    font.pixelSize: 10
                                                                    font.family: "monospace"
                                                                }
                                                            }
                                                        }
                                                    }

                                                    Text {
                                                        anchors.left: keyRow.right
                                                        anchors.leftMargin: 10
                                                        anchors.right: parent.right
                                                        anchors.verticalCenter: parent.verticalCenter
                                                        text: modelData.desc
                                                        color: root.cSubtext
                                                        font.pixelSize: 12
                                                        elide: Text.ElideRight
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Footer
                    Item {
                        width: parent.width
                        height: 16

                        Text {
                            anchors.left: parent.left
                            text: "Esc to close"
                            color: root.cOverlay
                            font.pixelSize: 11
                        }

                        Text {
                            anchors.right: parent.right
                            text: root.unlabelled > 0
                                  ? root.unlabelled + " unlabelled bind(s) hidden"
                                  : ""
                            color: root.cOverlay
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }
}
