import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Hyprland
import qs.services
import qs.common.widgets

QuickToggleButton {
    id: root
    toggled: BluetoothStatus.enabled
    buttonIcon: BluetoothStatus.connected ? "bluetooth_connected" : BluetoothStatus.enabled ? "bluetooth" : "bluetooth_disabled"
    onClicked: {
        Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter?.enabled
    }
    altAction: () => {
        // Quickshell.execDetached(["bash", "-c", `${Config.options.apps.bluetooth}`])
        // GlobalStates.sidebarRightOpen = false
    }
    StyledToolTip {
        content: "%1 | Right-click to configure".arg(
            (BluetoothStatus.firstActiveDevice?.name ?? "Bluetooth")
            + (BluetoothStatus.activeDeviceCount > 1 ? ` +${BluetoothStatus.activeDeviceCount - 1}` : "")
            )
    }
}
