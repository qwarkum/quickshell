import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.services
import qs.icons
import qs.common.widgets

QuickToggleButton {
    toggled: false
    materialSymbol: false
    buttonIcon: Icons.tor
    onClicked: {}//NetworkService.toggleWifi()
    altAction: () => {
        // Quickshell.execDetached(["bash", "-c", `${Networkservice.ethernet ? Config.options.apps.networkEthernet : Config.options.apps.network}`])
        // GlobalStates.sidebarRightOpen = false
    }
    StyledToolTip {
        content: "Tor"
    }
}
