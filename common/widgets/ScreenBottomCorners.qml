import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.styles
import qs.bar.modules
import qs.common.widgets

Variants {
    id: root
    model: Quickshell.screens
    property bool visible: Appearance.controlls.cornersVisible

    Scope {
        required property var modelData

        // --- Bottom-left corner ---
        PanelWindow {
            screen: modelData
            exclusiveZone: 0
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

        // --- Bottom-right corner ---
        PanelWindow {
            screen: modelData
            exclusiveZone: 0
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
