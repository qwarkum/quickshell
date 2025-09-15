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
    property bool visible: Appearance.controlls.barVisible || !Appearance.controlls.gameModeToggled

    PanelWindow {
        required property var modelData
        screen: modelData
        exclusiveZone: -1
        visible: root.visible
        WlrLayershell.namespace: "quickshell:screenCorners"
        WlrLayershell.layer: WlrLayer.Overlay

        // Panel positioning and appearance
        anchors {
            top: true
            left: true
            right: true
        }
            Layout.topMargin:50
        implicitHeight: Appearance.configs.barHeight - Appearance.configs.panelRadius
        color: "transparent"

        // Add rounded corners using the RoundCorner component
        RoundCorner {
            corner: RoundCorner.CornerEnum.TopLeft
            implicitSize: Appearance.configs.panelRadius
            color: "black"
            anchors {
                top: parent.top
                left: parent.left
            }
        }

        RoundCorner {
            corner: RoundCorner.CornerEnum.TopRight
            implicitSize: Appearance.configs.panelRadius
            color: "black"
            anchors {
                top: parent.top
                right: parent.right
            }
        }
    }
}