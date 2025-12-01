import QtQuick
import qs.common.widgets
import qs.styles

GroupButton {
    id: button
    property string buttonIcon
    property bool materialSymbol: true
    property bool enableFill: true
    baseWidth: 40
    baseHeight: 40
    clickedWidth: baseWidth + 20
    toggled: false
    buttonRadius: toggled ? Appearance.configs.full : Appearance.configs.full
    buttonRadiusPressed: Math.min(baseHeight, baseWidth) / 2 - 5

    contentItem: MaterialSymbol {
        anchors.centerIn: parent
        iconSize: 20
        fill: enableFill && toggled ? 1 : 0
        color: toggled ? Appearance.colors.panelBackground : Appearance.colors.textMain
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: buttonIcon
        font.family: materialSymbol ? Appearance.fonts.materialSymbolsRounded : Appearance.fonts.jetbrainsMonoNerd

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }
}
