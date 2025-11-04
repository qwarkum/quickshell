import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import qs.styles
import qs.bar.modules
import qs.common.widgets

Variants {
    id: root
    model: Quickshell.screens
    property bool visible: Config.cornersVisible && !Hyprland.focusedWorkspace?.hasFullscreen

    Scope {
        required property var modelData

        PanelWindow {
            screen: modelData
            exclusiveZone: -1
            visible: root.visible
            WlrLayershell.namespace: "quickshell:screenCorners"
            WlrLayershell.layer: WlrLayer.Overlay

            anchors {
                bottom: true
                left: true
            }

            implicitWidth: Appearance.configs.panelRadius
            implicitHeight: Appearance.configs.panelRadius
            color: "transparent"

            RoundCorner {
                corner: RoundCorner.CornerEnum.BottomLeft
                implicitSize: Appearance.configs.panelRadius
                anchors.bottom: parent.bottom
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
                bottom: true
                right: true
            }

            implicitWidth: Appearance.configs.panelRadius
            implicitHeight: Appearance.configs.panelRadius
            color: "transparent"

            RoundCorner {
                corner: RoundCorner.CornerEnum.BottomRight
                implicitSize: Appearance.configs.panelRadius
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                color: "black"
            }
        }
    }
}
