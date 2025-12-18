import qs.config
import qs.common.wallpaperSelector as WallpaperSelector
import QtQuick
import QtQuick.Shapes

Shape {
    id: root

    required property Panels panels
    required property Item bar

    anchors.fill: parent
    anchors.margins: 10
    anchors.leftMargin: Appearance.configs.barHeight
    preferredRendererType: Shape.CurveRenderer

    WallpaperSelector.Background {
        wrapper: root.panels.dashboard

        startX: (root.width - wrapper.width) / 2 - rounding
        startY: 0
    }
}
