import QtQuick
import QtQuick.Shapes
import qs.styles
import qs.example.TopPanel

Shape {
    id: root

    required property Panels panels

    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    Background {
        wrapper: root.panels.topPanel

        // The startX and startY are set relative to the Shape's coordinate system
        // Similar to Dashboard: startX is centered minus rounding, startY is at top
        startX: (root.width - wrapper.width) / 2 - Appearance.configs.panelRadius
        startY: 0
    }
}

