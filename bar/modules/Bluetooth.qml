import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.services
import qs.common.widgets

Item {
    id: root
    Layout.preferredWidth: Appearance.configs.rightContentModuleWidth

    MaterialSymbol {
        id: bluetoothIcon
        anchors.centerIn: parent
        text: BluetoothStatus.connected ? "bluetooth_connected" : BluetoothStatus.enabled ? "bluetooth" : "bluetooth_disabled"

        iconSize: 18
    }
}