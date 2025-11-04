import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common.components
import qs.common.widgets
import qs.common.utils
import qs.services
import qs.styles

Item {
    id: topWidgetsRoot

    property real brightness: 0.5
    property real lastBrightness: 0.5
    property bool isUpdating: false
    property var screen: topWidgetsRoot.QsWindow.window?.screen
    property var brightnessMonitor: BrightnessService.getMonitorForScreen(screen)

    implicitHeight: rowLayout.implicitHeight

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        spacing: 8

        ColumnLayout {
            Layout.fillWidth: true

            QuickSlider {
                id: slider
                visible: true
                toolTipWithDelay: true
                configuration: StyledSlider.Configuration.M
                value: topWidgetsRoot.brightnessMonitor?.brightness || 1
                onValueChanged: {
                    topWidgetsRoot.brightnessMonitor?.setBrightness(value)
                }
                materialSymbol: "brightness_6"
            }
        }
    }
}
