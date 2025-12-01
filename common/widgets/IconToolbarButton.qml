import QtQuick
import QtQuick.Layouts
import qs.styles

ToolbarButton {
    id: iconBtn
    implicitWidth: height

    colBackgroundToggled: Appearance.colors.secondary
    colBackgroundToggledHover: Appearance.colors.brightSecondary
    colRippleToggled: Appearance.colors.main
    property color colText: toggled ? Appearance.colors.bright : Appearance.colors.textMain

    contentItem: MaterialSymbol {
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        iconSize: 22
        text: iconBtn.text
        color: iconBtn.colText
        // animateChange: true
    }
}
