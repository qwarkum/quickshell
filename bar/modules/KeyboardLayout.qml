import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.services
import qs.common.widgets

Item {
    Layout.preferredWidth: Appearance.configs.rightContentModuleWidth
    Layout.preferredHeight: Appearance.configs.rightContentModuleWidth
    Layout.rightMargin: 10
    
    StyledText {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: HyprlandXkb.currentLayoutCode
        font.pixelSize: 15
        color: Appearance.colors.textMain
        animateChange: true
    }
}