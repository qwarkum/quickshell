import qs.styles
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property bool vertical: false
    property real padding: 0
    implicitWidth: vertical ? Appearance.configs.barHeight : (gridLayout.implicitWidth + padding * 2)
    implicitHeight: vertical ? (gridLayout.implicitHeight + padding * 2) : Appearance.configs.barHeight
    default property alias items: gridLayout.children
    property var startRadius // left - top
    property var endRadius // right - bottom

    Rectangle {
        id: background
        anchors {
            fill: parent
            topMargin: root.vertical ? 0 : (Appearance.configs.barHeight - Appearance.configs.moduleHeight) / 2
            bottomMargin: root.vertical ? 0 : (Appearance.configs.barHeight - Appearance.configs.moduleHeight) / 2
            leftMargin: root.vertical ? 4 : 0
            rightMargin: root.vertical ? 4 : 0
        }
        color: Config.options?.bar.borderless ? "transparent" : Appearance.colors.moduleBackground
        topLeftRadius: startRadius
        bottomLeftRadius: root.vertical ? endRadius: startRadius
        topRightRadius: root.vertical ? startRadius: endRadius
        bottomRightRadius: endRadius
    }

    GridLayout {
        id: gridLayout
        columns: root.vertical ? 1 : -1
        anchors {
            verticalCenter: root.vertical ? undefined : parent.verticalCenter
            horizontalCenter: root.vertical ? parent.horizontalCenter : undefined
            left: root.vertical ? undefined : parent.left
            right: root.vertical ? undefined : parent.right
            top: root.vertical ? parent.top : undefined
            bottom: root.vertical ? parent.bottom : undefined
            margins: root.padding
        }
        columnSpacing: 4
        rowSpacing: 12
    }
}