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
            iconName: "database"
            percentage: ResourceUsage.memoryUsedPercentage
            warningThreshold: 95
        }

        Resource {
            iconName: "swap_horiz"
            percentage: ResourceUsage.swapUsedPercentage
            shown: (percentage > 0) || 
                (MprisController.activePlayer?.trackTitle == null) ||
                root.showResources
            Layout.leftMargin: shown ? 6 : 0
            warningThreshold: 85
        }

        Resource {
            iconName: "memory"
            percentage: ResourceUsage.cpuUsage
            shown: !(MprisController.activePlayer?.trackTitle?.length > 0) ||
                root.showResources
            Layout.leftMargin: shown ? 6 : 0
            warningThreshold: 90
        }
    }
}
