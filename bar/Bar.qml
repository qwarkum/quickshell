import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.bar.modules
import qs.common.widgets
import qs.common.ipcHandlers

Variants {
    id: bar
    model: Quickshell.screens

    PanelWindow {
        id: bar
        screen: modelData
        color: "transparent"
        WlrLayershell.namespace: "quickshell:bar"
        // Panel positioning
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: Appearance.configs.barHeight
        visible: Appearance.controlls.barVisible

        required property var modelData

        function toggle() {
            Appearance.controlls.barVisible = !Appearance.controlls.barVisible
        }

        BarIpcHandler { root: bar }

        Rectangle {
            id: barRectangle
            anchors.fill: parent
            border.color: Appearance.colors.moduleBorder
            border.width: Appearance.configs.windowBorderWidth
            color: Appearance.colors.panelBackground

            // --- Animate opacity and height ---
            opacity: Appearance.controlls.barVisible ? 1 : 0
            height: Appearance.controlls.barVisible ? Appearance.configs.barHeight : 0

            Behavior on opacity {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }
            Behavior on height {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }

            RowLayout {
                id: barContentRow
                anchors.fill: parent
                opacity: barRectangle.opacity // fades with bar
                visible: opacity > 0.01

                Workspaces { Layout.leftMargin: 18 }
                Media { Layout.leftMargin: 20 }

                Item { Layout.fillWidth: true }
                DateTime {}
                Item { Layout.fillWidth: true }

                RightContent { Layout.rightMargin: 10 }
                Battery { Layout.rightMargin: 10 }
            }
        }

        BarBottomCorners {
            id: barBottomCorners
            visible: Appearance.controlls.cornersVisible

            Behavior on visible {
                animation: Appearance.animation.elementMove.numberAnimation.createObject(bar)
            }
        }

        Behavior on exclusiveZone {
            animation: Appearance.animation.elementMove.numberAnimation.createObject(bar)
        }
    }
}