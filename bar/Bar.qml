import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.bar.modules
import qs.common.widgets

Variants {
    model: Quickshell.screens

    PanelWindow {
        required property var modelData
        screen: modelData

        // Panel positioning and appearance
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: DefaultStyle.configs.barHeight

        Rectangle {
            anchors.fill: parent
            border.color: DefaultStyle.colors.moduleBorder
            border.width: DefaultStyle.configs.windowBorderWidth
            color: DefaultStyle.colors.panelBackground

            // Main panel layout
            RowLayout {
                anchors.fill: parent
                spacing: 10

                // Workspaces indicator
                Workspaces { Layout.leftMargin: 5 }
                Media { Layout.leftMargin: 20 }

                // Spacer
                Item { Layout.fillWidth: true }
                DateTime { Layout.alignment: Qt.AlignVCenter }
                Item { Layout.fillWidth: true }
                
                // WallpaperSelector {}
                RightSidebar {}
                Battery { Layout.rightMargin: 10 }
            }
        }

        BarBottomCorners {}
    }
}