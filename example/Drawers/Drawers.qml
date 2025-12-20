import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
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
