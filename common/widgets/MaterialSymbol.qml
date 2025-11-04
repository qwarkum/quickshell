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
}
