import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.bar.modules
import qs.common.widgets

Variants {
    id: root
    model: Quickshell.screens
    property bool visible: Appearance.controlls.cornersVisible

    PanelWindow {
        required property var modelData
        screen: modelData
        exclusiveZone: 0
        visible: Appearance.controlls.cornersVisible
        WlrLayershell.namespace: "quickshell:screenCorners"
        WlrLayershell.layer: WlrLayer.Overlay

        // Panel positioning and appearance
        anchors {
            bottom: true
            left: true
            right: true
        }
        implicitHeight: Appearance.configs.barHeight - Appearance.configs.panelRadius
        color: "transparent"

        // Add rounded corners using the RoundCorner component
        RoundCorner {
            corner: RoundCorner.CornerEnum.BottomLeft
            implicitSize: Appearance.configs.panelRadius
            color: "black"
            anchors {
                top: parent.top
                left: parent.left
            }
        }

        RoundCorner {
            corner: RoundCorner.CornerEnum.BottomRight
            implicitSize: Appearance.configs.panelRadius
            color: "black"
            anchors {
                top: parent.top
                right: parent.right
            }
        }
    }
}