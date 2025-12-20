import QtQuick
import Quickshell
import qs.styles
import qs.common.widgets

PanelWindow {

    color: "transparent"
    visible: Config.launcherOpen

    anchors.top: true
    exclusiveZone: 0

    implicitWidth: 500
    implicitHeight: 2*Appearance.configs.panelRadius

    Rectangle {
        anchors.fill: parent
        anchors.rightMargin: Appearance.configs.panelRadius
        anchors.leftMargin: Appearance.configs.panelRadius
        radius: Appearance.configs.windowRadius
        topLeftRadius: 0
        topRightRadius: 0
        color: "green"
    }
}