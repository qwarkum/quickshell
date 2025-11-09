import QtQuick
import qs.styles

Text {
    id: root
    property real iconSize: 16
    property real iconWeight: 400
    property real fill: 0
    renderType: Text.NativeRendering
    font {
        family: Appearance.fonts.materialSymbolsRounded
        pixelSize: iconSize
        weight: iconWeight
        variableAxes: { 
            "FILL": fill,
            // "wght": font.weight,
            // "GRAD": 0,
            "opsz": iconSize,
        }
    }
    color: Appearance.colors.textMain

    // Behavior on fill { // Leaky leaky, no good
    //     NumberAnimation {
    //         duration: Appearance?.animation.elementMoveFast.duration ?? 200
    //         easing.type: Appearance?.animation.elementMoveFast.type ?? Easing.BezierSpline
    //         easing.bezierCurve: Appearance?.animation.elementMoveFast.bezierCurve ?? [0.34, 0.80, 0.34, 1.00, 1, 1]
    //     }
    // }
}
