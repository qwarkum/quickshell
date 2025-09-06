import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.bar.modules
import qs.common.widgets

Item {
    RoundCorner {
        corner: RoundCorner.CornerEnum.TopLeft
        implicitSize: DefaultStyle.configs.panelRadius
        color: "black"
        anchors {
            top: parent.top
            left: parent.left
        }
    }
    RoundCorner {
        corner: RoundCorner.CornerEnum.TopRight
        implicitSize: DefaultStyle.configs.panelRadius
        color: "black"
        anchors {
            top: parent.top
            right: parent.right
        }
    }
}