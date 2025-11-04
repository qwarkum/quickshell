import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.common.widgets

Variants {
    id: root
    model: Quickshell.screens
    property bool visible: Config.barOpen || !Config.gameModeToggled

    Scope {
        required property var modelData

        // --- Top-left corner ---
        PanelWindow {
            screen: modelData
            exclusiveZone: 0
            visible: root.visible
            WlrLayershell.namespace: "quickshell:screenCorners"
            // WlrLayershell.layer: WlrLayer.Overlay

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
                color: Appearance.colors.panelBackground
            }
        }

        // --- Top-right corner ---
        PanelWindow {
            screen: modelData
            exclusiveZone: 0
            visible: root.visible
            WlrLayershell.namespace: "quickshell:screenCorners"
            // WlrLayershell.layer: WlrLayer.Overlay

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
                color: Appearance.colors.panelBackground
            }
        }
    }
}