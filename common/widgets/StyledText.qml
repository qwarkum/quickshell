import QtQuick
import QtQuick.Layouts
import qs.styles

Text {
    id: root
    // renderType: Text.NativeRendering
    property bool animateChange: false
    property real animationDistanceX: 0
    property real animationDistanceY: 6

    verticalAlignment: Text.AlignVCenter
    font {
        hintingPreference: Font.PreferFullHinting
        family: Appearance.fonts.rubik
        pixelSize: 15
        weight: 400
    }
    color: Appearance.colors.textMain
    linkColor: Appearance.colors.textMain

    component Anim: NumberAnimation {
        target: root
        duration: 300 / 2
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
    }

    Behavior on text {
        id: textAnimationBehavior
        enabled: root.animateChange

        SequentialAnimation {
            alwaysRunToEnd: true
            ParallelAnimation {
                Anim {
                    property: "scale"
                    to: 0.8
                    easing.type: Easing.InSine
                }
                Anim {
                    property: "opacity"
                    to: 0
                    easing.type: Easing.InSine
                }
            }
            PropertyAction {} // Text update happens here
            ParallelAnimation {
                Anim {
                    property: "scale"
                    to: 1
                    easing.type: Easing.OutSine
                }
                Anim {
                    property: "opacity"
                    to: 1
                    easing.type: Easing.OutSine
                }
            }
        }
    }
}
