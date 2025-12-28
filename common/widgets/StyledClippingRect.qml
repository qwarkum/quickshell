import Quickshell.Widgets
import QtQuick
import qs.styles

ClippingRectangle {
    id: root

    color: "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 300
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.animationCurves.standard
        }
    }
}
