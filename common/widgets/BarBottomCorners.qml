import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.bar.modules
import qs.common.widgets

PanelWindow {
    id: root
    screen: modelData
    exclusiveZone: 0
    WlrLayershell.namespace: "quickshell:screenCorners"

    // Panel positioning and appearance
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Appearance.configs.barHeight - Appearance.configs.panelRadius
    color: "transparent"


    // Add rounded corners using the RoundCorner component
    RoundCorner {
        corner: RoundCorner.CornerEnum.TopLeft
        implicitSize: Appearance.configs.panelRadius
        color: Appearance.colors.panelBackground
        anchors {
            top: parent.top
            left: parent.left
        }
    }

    RoundCorner {
        corner: RoundCorner.CornerEnum.TopRight
        implicitSize: Appearance.configs.panelRadius
        color: Appearance.colors.panelBackground
        anchors {
            top: parent.top
            right: parent.right
        }
    }
}