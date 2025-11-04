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
                value: Pipewire.defaultAudioSource?.audio.volume ?? 0
                configuration: StyledSlider.Configuration.M
                onValueChanged: Pipewire.defaultAudioSource.audio.volume = value
                toolTipWithDelay: true
                materialSymbol: Pipewire.defaultAudioSource?.audio.muted ? "mic_off" : "mic"
            }
        }
    }
}
