import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.styles
import qs.common.widgets

Item {
    Rectangle {
        id: sidebarRightContainer
        anchors.fill: parent
        anchors.leftMargin: Appearance.configs.panelRadius
        color: Appearance.colors.panelBackground

        RoundCorner {
            corner: RoundCorner.CornerEnum.BottomRight
            implicitSize: Appearance.configs.panelRadius
            color: Appearance.colors.panelBackground
            anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: -Appearance.configs.panelRadius
            }
        }
        RoundCorner {
            corner: RoundCorner.CornerEnum.TopRight
            implicitSize: Appearance.configs.panelRadius
            color: Appearance.colors.panelBackground
            anchors {
                top: parent.top
                left: parent.left
                leftMargin: -Appearance.configs.panelRadius
            }
        }

        ColumnLayout {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                leftMargin: 20
                rightMargin: 20
            }

            SidebarRightHeader {
                Layout.fillWidth: true
            }

            SidebarRightControlls {
                Layout.fillWidth: true
            }
        }

        transform: Translate { x: sidebarRightContainer.width * (1 - slideProgress) }
    }
}