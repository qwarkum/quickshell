import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.services
import qs.common.widgets

Item {
    id: root
    Layout.preferredWidth: DefaultStyle.configs.rightSidebarModuleWidth

    MaterialSymbol {
        id: bluetoothIcon
        anchors.centerIn: parent
        text: BluetoothService.bluetoothIcon

        iconSize: 18
    }
}