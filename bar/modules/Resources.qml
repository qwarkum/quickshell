import QtQuick
import QtQuick.Layouts
import qs.common.widgets
import qs.services
import qs.styles

Item {
    id: root
    implicitWidth: resourcesModule.width + 10
    
    property real percentage: BatteryService.percentage

    Rectangle {
        id: resourcesModule
        width: rowLayout.implicitWidth
        height: Appearance.configs.moduleHeight
        radius: height / 2
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 2

        color: Appearance.colors.moduleBackground
        border.color: Appearance.colors.moduleBorder
        border.width: Appearance.configs.windowBorderWidth

        RowLayout {
            id: rowLayout

            spacing: 0
            anchors.centerIn: parent

            Resource {
                iconName: "memory"
                percentage: ResourceUsage.memoryUsedPercentage
                warningThreshold: 95
            }

            Resource {
                iconName: "swap_horiz"
                percentage: ResourceUsage.swapUsedPercentage
                Layout.leftMargin: shown ? 6 : 0
                warningThreshold: 85
            }

            Resource {
                iconName: "planner_review"
                percentage: ResourceUsage.cpuUsage
                Layout.leftMargin: shown ? 6 : 0
                warningThreshold: 90
            }
        }
    }
}