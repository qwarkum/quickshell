import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.bar.modules
import qs.common.widgets

Variants {
    id: root
    model: Quickshell.screens
    property bool visible: true

    PanelWindow {
        required property var modelData
        screen: modelData
        exclusiveZone: 0
        visible: root.visible

        // Panel positioning and appearance
        anchors {
            bottom: true
            left: true
            right: true
        }
        implicitHeight: DefaultStyle.configs.barHeight - DefaultStyle.configs.panelRadius
        color: "transparent"

        // Add rounded corners using the RoundCorner component
        RoundCorner {
            corner: RoundCorner.CornerEnum.BottomLeft
            implicitSize: DefaultStyle.configs.panelRadius
            color: "black"
            anchors {
                top: parent.top
                left: parent.left
            }
        }

        RoundCorner {
            corner: RoundCorner.CornerEnum.BottomRight
            implicitSize: DefaultStyle.configs.panelRadius
            color: "black"
            anchors {
                top: parent.top
                right: parent.right
            }
        }
    }
}