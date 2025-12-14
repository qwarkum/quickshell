import QtQuick
import QtQuick.Layouts
import qs.common.widgets
import qs.services
import qs.styles

MouseArea {
    id: root
    property bool showResources: true
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: 45
    hoverEnabled: true

    RowLayout {
        id: rowLayout

        spacing: 0
        anchors.fill: parent

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
