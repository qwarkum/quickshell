import QtQuick
import Quickshell
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
            name: "example-drawers"
            WlrLayershell.namespace: "quickshell:example-drawers"
            WlrLayershell.layer: WlrLayer.Overlay
            color: "transparent"

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
                    topPanelVisible: true
                }
            }
        }
    }
}
