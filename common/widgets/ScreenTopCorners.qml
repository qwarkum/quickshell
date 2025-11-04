import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import qs.styles
import qs.common.widgets

Variants {
    id: root
    model: Quickshell.screens
    property bool visible: Config.cornersVisible && !Hyprland.focusedWorkspace?.hasFullscreen

    Scope {
        required property var modelData

        // Connections {
        //     target: Config
        //     function onBarOpenChanged() {
        //         root.visible = Config.barOpen || (Config.cornersVisible && !Hyprland.focusedWorkspace?.hasFullscreen)
        //     }
        // }

        PanelWindow {
            screen: modelData
            exclusiveZone: -1
            visible: root.visible
            WlrLayershell.namespace: "quickshell:screenCorners"
            WlrLayershell.layer: WlrLayer.Overlay

            anchors {
                top: true
                left: true
            }

            implicitWidth: Appearance.configs.panelRadius
            implicitHeight: Appearance.configs.panelRadius
            color: "transparent"

            RoundCorner {
                corner: RoundCorner.CornerEnum.TopLeft
                implicitSize: Appearance.configs.panelRadius
                anchors.top: parent.top
                anchors.left: parent.left
                color: "black"
            }
        }

        PanelWindow {
            screen: modelData
            exclusiveZone: -1
            visible: root.visible
            WlrLayershell.namespace: "quickshell:screenCorners"
            WlrLayershell.layer: WlrLayer.Overlay

            anchors {
                top: true
                right: true
            }

            implicitWidth: Appearance.configs.panelRadius
            implicitHeight: Appearance.configs.panelRadius
            color: "transparent"

            RoundCorner {
                corner: RoundCorner.CornerEnum.TopRight
                implicitSize: Appearance.configs.panelRadius
                anchors.top: parent.top
                anchors.right: parent.right
                color: "black"
            }
        }
    }
}
