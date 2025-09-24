import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.icons
import qs.services
import qs.common.widgets
import "./quickToggles/"

Item {
    id: sidebarRightControllsRoot
    Layout.topMargin: 30
    implicitHeight: sidebarRightBackground.implicitHeight
    implicitWidth: sidebarRightBackground.implicitWidth
    property int padding: 7

    Rectangle {
        id: sidebarRightBackground

        anchors.fill: parent
        implicitWidth: Appearance.configs.sidebarWidth - 10 * 2
        color: "transparent"
        radius: Appearance.configs.panelRadius + sidebarRightControllsRoot.padding

        ColumnLayout {
            anchors.fill: parent
            spacing: 10

            ButtonGroup {
                z: 999
                Layout.alignment: Qt.AlignHCenter
                spacing: sidebarRightControllsRoot.padding
                padding: sidebarRightControllsRoot.padding
                color: Appearance.colors.moduleBackground

                NetworkToggle { }

                BluetoothToggle { }

                PowerSaverToggle { }

                GameModeToggle { }

                TorToggle { }
            }

            CenterWidgetGroup {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}