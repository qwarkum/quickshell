import QtQuick
import qs.common.widgets
import qs.styles

GroupButton {
    id: button
    property string buttonIcon
    property bool enableFill
    baseWidth: 50
    baseHeight: 50
    clickedWidth: baseWidth + 20
    toggled: false
    buttonRadius: Appearance.configs.panelRadius
    buttonRadiusPressed: Math.min(baseHeight, baseWidth) / 2 - 10

    contentItem: MaterialSymbol {
        anchors.centerIn: parent
        iconSize: 26
        fill: enableFill && toggled ? 1 : 0
        color: toggled ? Appearance.colors.panelBackground : Appearance.colors.white
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: buttonIcon

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }

}
