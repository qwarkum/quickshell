import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.services
import qs.common.widgets

Item {
    id: root
    implicitWidth: rowLayout.implicitWidth + rowLayout.spacing * 2
    implicitHeight: 32
    
    property real percentage: BatteryService.percentage

    RowLayout {
        id: rowLayout
        spacing: 8
        anchors.centerIn: parent

        CircularProgress {
            id: batteryProgress
            Layout.alignment: Qt.AlignVCenter
            lineWidth: 2
            value: root.percentage
            implicitSize: 28
            colSecondary: BatteryService.progressBackground
            colPrimary: BatteryService.progressColor
            enableAnimation: true

            MaterialSymbol {
                id: batteryIcon
                anchors.centerIn: parent
                text: BatteryService.batteryIcon
                color: BatteryService.progressColor
                
                iconSize: 18
                fill: 1
            }
        }
    }
}