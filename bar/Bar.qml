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
        color: "transparent"

        // Panel positioning and appearance
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: DefaultStyle.configs.barHeight
        exclusiveZone: DefaultStyle.configs.barHeight

        Rectangle {
            anchors.fill: parent
            border.color: DefaultStyle.colors.moduleBorder
            border.width: DefaultStyle.configs.windowBorderWidth
            color: DefaultStyle.colors.panelBackground

            ScreenTopCorners {
                visible: true
                anchors.fill: parent
            }

            // Main panel layout
            RowLayout {
                anchors.fill: parent
                visible: true

                // Workspaces indicator
                Workspaces { Layout.leftMargin: 5 }
                Media { Layout.leftMargin: 20 }

                // Spacer
                Item { Layout.fillWidth: true }
                DateTime {}
                Item { Layout.fillWidth: true }
                
                RightSidebar {}
                Battery { Layout.rightMargin: 10 }
            }
        }

        BarBottomCorners {}
    }
}