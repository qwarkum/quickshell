import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.bar.modules.sidebarRight

Item {
    id: sidebarContainer
    width: rightContentLayout.width + 15
    height: Appearance.configs.moduleHeight

    Rectangle {
        id: background
        anchors.fill: parent
        color: Appearance.colors.moduleBackground
        border.color: Appearance.colors.moduleBorder
        border.width: Appearance.configs.windowBorderWidth
        radius: height / 2
        opacity: mouse.containsMouse || sidebarRight.visible ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            sidebarRight.toggle()
        }
    }
    
    RowLayout {
        id: rightContentLayout
        anchors.centerIn: parent
        spacing: 10
        
        Audio {}
        Network {}
        Bluetooth {}
    }

    SidebarRight {
        id: sidebarRight
    }
}