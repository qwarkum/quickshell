import QtQuick
import qs.styles

StyledSlider { 
    id: quickSlider
    required property string materialSymbol
    configuration: StyledSlider.Configuration.M
    stopIndicatorValues: []
    
    MaterialSymbol {
        id: icon
        property bool nearFull: quickSlider.value >= 0.9
        anchors {
            verticalCenter: parent.verticalCenter
            right: nearFull ? quickSlider.handle.right : parent.right
            rightMargin: quickSlider.nearFull ? 14 : 8
        }
        iconSize: 20
        color: nearFull ? Appearance.colors.panelBackground : Appearance.colors.main
        text: quickSlider.materialSymbol

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
        Behavior on anchors.rightMargin {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
    }
}