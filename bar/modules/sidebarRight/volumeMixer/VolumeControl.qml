import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.common.components
import qs.common.widgets
import qs.common.utils
import qs.services
import qs.styles

Item {
    id: root

    implicitHeight: rowLayout.implicitHeight

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        spacing: 8

        ColumnLayout {
            Layout.fillWidth: true

            QuickSlider {
                id: slider
                value: Pipewire.defaultAudioSink?.audio.volume ?? 0
                configuration: StyledSlider.Configuration.M
                onValueChanged: Pipewire.defaultAudioSink.audio.volume = value
                materialSymbol: Pipewire.defaultAudioSink?.audio.muted ? "volume_off" : "volume_up"
                toolTipWithDelay: true
            }
        }
    }
}
