import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.common.widgets
import qs.services
import qs.styles


Item {
    id: root

    AudioService {
        id: audioService
    }

    ColumnLayout {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        
        VolumeControl {
            id: volumeControl
            Layout.margins: 10
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            visible: true
        }

        MicControl {
            id: micControl
            Layout.margins: 10
            Layout.topMargin: -5
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            visible: true
        }

        BrightnessControl {
            id: brightnessControl
            Layout.margins: 10
            Layout.topMargin: -5
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            visible: true
        }
    }
}