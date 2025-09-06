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

    readonly property bool isLan: NetworkService.networkIcon == "lan"

    MaterialSymbol {
        id: networkIcon
        anchors.centerIn: parent
        text: NetworkService.networkIcon

        iconSize: isLan ? 18 : 20
    }
}