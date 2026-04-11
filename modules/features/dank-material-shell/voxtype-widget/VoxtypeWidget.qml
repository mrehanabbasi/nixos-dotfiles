import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services

// Simple daemon - just monitors voxtype and shows toasts
Item {
    id: root

    property string currentStatus: "idle"
    property bool isActive: currentStatus === "recording" || currentStatus === "transcribing"

    Component.onCompleted: {
        console.info("=== VOXTYPE DAEMON STARTED ===");
    }

    // Voxtype status monitor
    Process {
        id: voxtypeProcess
        command: ["voxtype", "status", "--follow", "--format", "json"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                console.log("=== VOXTYPE RAW:", data);
                try {
                    const status = JSON.parse(data);
                    root.currentStatus = status.class || "idle";
                    console.log("=== VOXTYPE STATUS:", root.currentStatus);
                } catch (e) {
                    console.error("=== VOXTYPE PARSE ERROR:", e);
                }
            }
        }
    }

    // Show toast notification when status changes
    onCurrentStatusChanged: {
        console.log("=== VOXTYPE STATUS CHANGED TO:", currentStatus);
        if (currentStatus === "recording") {
            ToastService.showInfo("Voxtype", "Recording...");
        } else if (currentStatus === "transcribing") {
            ToastService.showInfo("Voxtype", "Transcribing...");
        }
    }
}
