// modules/RightSidebar.qml
import QtQuick
import QtQuick.Layouts
import qs.styles


Rectangle {
    width: rightSidebarLayout.width + 25
    height: DefaultStyle.configs.moduleHeight
    color: DefaultStyle.colors.moduleBackground
    border.color: DefaultStyle.colors.moduleBorder
    border.width: DefaultStyle.configs.windowBorderWidth
    radius: height / 2
    
    RowLayout {
        id: rightSidebarLayout
        anchors.centerIn: parent
        spacing: 15
        
        Audio {}
        Network {}
        Bluetooth {}
    }
}
