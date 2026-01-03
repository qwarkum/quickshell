import qs.styles
import QtQuick
import QtQuick.Shapes

ShapePath {
    id: root

    required property Wrapper wrapper
    required property var panels
    readonly property real rounding: Appearance.configs.panelRadius
    readonly property bool flatten: wrapper.height < rounding * 2
    readonly property real roundingY: flatten ? wrapper.height / 2 : rounding
    
    // Calculate utilsRoundingX locally without requiring sidebar
    readonly property real utilsWidthDiff: panels.sidebarRightPanel.width - wrapper.width
    readonly property real utilsRoundingX: utilsWidthDiff < rounding * 2 ? utilsWidthDiff / 2 : rounding

    strokeWidth: -1
    fillColor: Appearance.colors.panelBackground

    PathLine {
        relativeX: -(root.wrapper.width + root.rounding)
        relativeY: 0
    }
    PathArc {
        relativeX: root.rounding
        relativeY: -root.roundingY
        radiusX: root.rounding
        radiusY: Math.min(root.rounding, root.wrapper.height)
        direction: PathArc.Counterclockwise
    }
    PathLine {
        relativeX: 0
        relativeY: -(root.wrapper.height - root.roundingY * 2)
    }
    PathArc {
        relativeX: root.utilsRoundingX
        relativeY: -root.roundingY
        radiusX: root.utilsRoundingX
        radiusY: Math.min(root.rounding, root.wrapper.height)
    }
    PathLine {
        relativeX: root.wrapper.height > 0 ? root.wrapper.width - root.rounding - root.utilsRoundingX : root.wrapper.width
        relativeY: 0
    }
    PathArc {
        relativeX: root.rounding
        relativeY: -root.rounding
        radiusX: root.rounding
        radiusY: root.rounding
        direction: PathArc.Counterclockwise
    }

    Behavior on fillColor {
        ColorAnimation {
            duration: 400
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
        }
    }
}
