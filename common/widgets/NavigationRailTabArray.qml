import QtQuick
import QtQuick.Layouts
import qs.styles

Item {
    id: root
    property int currentIndex: 0
    property bool expanded: false
    default property alias data: tabBarColumn.data  
    implicitHeight: tabBarColumn.implicitHeight
    implicitWidth: tabBarColumn.implicitWidth
    Layout.topMargin: 15

    Rectangle {
        property real itemHeight: tabBarColumn.children[0]?.baseSize ?? 56
        property real baseHighlightHeight: tabBarColumn.children[0]?.baseHighlightHeight ?? 56
        anchors {
            top: tabBarColumn.top
            left: tabBarColumn.left
            topMargin: (itemHeight + tabBarColumn.spacing) * root.currentIndex + 
               (root.expanded ? 0 : ((itemHeight - baseHighlightHeight) / 2))
        }
        radius: 15
        color: Appearance.colors.secondary
        implicitHeight: root.expanded ? itemHeight : baseHighlightHeight
        implicitWidth: tabBarColumn?.children[root.currentIndex]?.visualWidth ?? baseHighlightHeight

        Behavior on anchors.topMargin {
            NumberAnimation {
                duration: Appearance.animationCurves.expressiveFastSpatialDuration
                easing.type: Appearance.animation.elementMove.type
                easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
            }
        }
    }

    ColumnLayout {
        id: tabBarColumn
        anchors.fill: parent
        spacing: 10
    }
}
