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
        implicitHeight: parent.height - 10 * 2
        implicitWidth: Appearance.configs.sidebarWidth - 10 * 2
        color: "transparent"
        radius: Appearance.configs.panelRadius + sidebarRightControllsRoot.padding

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: sidebarPadding
            spacing: sidebarPadding

            ButtonGroup {
                Layout.alignment: Qt.AlignHCenter
                spacing: sidebarRightControllsRoot.padding
                padding: sidebarRightControllsRoot.padding
                color: Appearance.colors.moduleBackground

                NetworkToggle { }

                BluetoothToggle { }

                PowerSaverToggle { }

                GameModeToggle { }

                VpnToggle { }
            }
        }

        function handleButtonPress(pressedButton) {
            // Get all buttons
            var buttons = [wifiButton, bluetoothButton, powerButton, gameButton, vpnButton]
            var pressedIndex = buttons.indexOf(pressedButton)
            
            // Expand the pressed button
            pressedButton.expand()
            
            // Compress neighbors from the side of the pressed button
            if (pressedIndex > 0) {
                buttons[pressedIndex - 1].compressRight()
            }
            if (pressedIndex < buttons.length - 1) {
                buttons[pressedIndex + 1].compressLeft()
            }
        }
    }
}