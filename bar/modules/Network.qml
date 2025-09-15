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
        id: networkIcon
        anchors.centerIn: parent
        text: NetworkService.networkIcon

        iconSize: NetworkService.ethernet ? 18 : 20
    }
}