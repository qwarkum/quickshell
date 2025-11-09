import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.services
import qs.common.widgets

Item {
    id: batteryRoot
    implicitWidth: batteryModule.width
    
    property real percentage: BatteryService.percentage

    Rectangle {
        id: batteryModule
        width: batteryLayout.implicitWidth
        height: Appearance.configs.moduleHeight
        radius: height / 2
        anchors.verticalCenter: parent.verticalCenter

        color: Appearance.colors.moduleBackground
        border.color: Appearance.colors.moduleBorder
        border.width: Appearance.configs.windowBorderWidth

        RowLayout {
            id: batteryLayout
            anchors.fill: parent
            anchors.leftMargin: batteryProgress.lineWidth

            CircularProgress {
                id: batteryProgress
                Layout.alignment: Qt.AlignVCenter
                lineWidth: 2
                value: batteryRoot.percentage
                implicitSize: 26
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

            Item {
                Layout.preferredWidth: 20
                Layout.preferredHeight: parent.height
                Layout.leftMargin: 2
                Layout.rightMargin: 12
                
                StyledText {
                    id: batteryPercentage
                    width: parent.width
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    text: (percentage * 100).toFixed(0)
                    color: BatteryService.progressColor
                    font.pixelSize: 15
                }
            }
        }
    }
}