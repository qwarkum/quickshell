import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.styles
import qs.example.Drawers

Variants {
    model: Quickshell.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        PanelWindow {
            id: win

            screen: scope.modelData
            WlrLayershell.namespace: "quickshell:example-drawers"
            WlrLayershell.layer: WlrLayer.Overlay
            color: "transparent"
            exclusiveZone: 0
            WlrLayershell.exclusionMode: ExclusionMode.Ignore
            focusable: panels.topPanelVisible
            WlrLayershell.keyboardFocus: panels.topPanelVisible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            // Keep window alive for corner animation; shrink input to nothing when hidden
            mask: panels.topPanelVisible ? Region { item: panels.topPanel } : Region { width: 0; height: 0 }

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            Item {
                anchors.fill: parent

                Backgrounds {
                    panels: panels
                }

                Panels {
                    id: panels

                    screen: scope.modelData
                }

                // Close when clicking outside / losing grab
                HyprlandFocusGrab {
                    id: focusGrab
                    windows: [win]
                    active: panels.topPanelVisible
                    onCleared: panels.topPanelVisible = false
                }

                // Close on Esc
                Keys.onPressed: event => {
                    if (!panels.topPanelVisible)
                        return;
                    if (event.key === Qt.Key_Escape) {
                        panels.topPanelVisible = false;
                        event.accepted = true;
                    }
                }

                // IPC handler for toggling the panel
                IpcHandler {
                    target: "topPanel"

                    function toggle() {
                        panels.toggle()
                    }

                    function show() {
                        panels.topPanelVisible = true
                    }

                    function hide() {
                        panels.topPanelVisible = false
                    }
                }
            }
        }
    }
}
