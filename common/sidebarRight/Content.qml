import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.styles
import qs.common.widgets

Item {
    id: root
    implicitWidth: Appearance.configs.sidebarWidth


    Rectangle {
        id: sidebarRightContainer
        anchors.fill: parent
        color: Appearance.colors.panelBackground

        SidebarRightControls {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: parent.right
                margins: 12
            }
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}