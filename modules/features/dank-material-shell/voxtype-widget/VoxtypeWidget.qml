import QtQuick
import Quickshell
import Quickshell.Io
import qs.Modules.Plugins

PluginComponent {
    id: root

    Component.onCompleted: {
        setVisibilityOverride(false);
    }

    QtObject {
        id: voxtypeStatus
        property string text: "idle"
    }

    Process {
        id: voxtypeProcess
        command: ["voxtype", "status", "--follow", "--format", "json"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    const status = JSON.parse(data);
                    const cls = status.class || "idle";
                    voxtypeStatus.text = cls;
                    root.setVisibilityOverride(cls === "recording" || cls === "transcribing");
                } catch (e) {
                    console.error("voxtype parse error:", e);
                }
            }
        }
    }

    horizontalBarPill: Component {
        Text {
            text: voxtypeStatus.text === "recording" ? "󰻂" : "󰔮"
            color: voxtypeStatus.text === "recording" ? "#f38ba8" : "#cdd6f4"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            font.bold: true
        }
    }

    verticalBarPill: Component {
        Text {
            text: voxtypeStatus.text === "recording" ? "󰻂" : "󰔮"
            color: voxtypeStatus.text === "recording" ? "#f38ba8" : "#cdd6f4"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            font.bold: true
        }
    }
}
