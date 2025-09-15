import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services
import qs.common.widgets

QuickToggleButton {
    toggled: NetworkService.wifiEnabled
    buttonIcon: NetworkService.wifiIcon
    onClicked: NetworkService.toggleWifi()
    enableFill: false
    altAction: () => {
        // Quickshell.execDetached(["bash", "-c", `${Networkservice.ethernet ? Config.options.apps.networkEthernet : Config.options.apps.network}`])
        // GlobalStates.sidebarRightOpen = false
    }
    StyledToolTip {
        content: "%1 | Right-click to configure".arg(NetworkService.networkName)
    }
}
