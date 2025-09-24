import qs.common.widgets
import qs.services
import qs.styles
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

RippleButton {
    id: button
    required property bool input

    buttonRadius: 10

    implicitHeight: contentItem.implicitHeight + 6 * 2
    implicitWidth: contentItem.implicitWidth + 6 * 2

    contentItem: RowLayout {
        anchors.fill: parent
        anchors.margins: 5
        spacing: 5

        MaterialSymbol {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: false
            Layout.leftMargin: 5
            color: Appearance.colors.white
            iconSize: 24
            text: input ? "mic_external_on" : "media_output"
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.rightMargin: 5
            spacing: 0
            StyledText {
                Layout.fillWidth: true
                elide: Text.ElideRight
                font.pixelSize: 16
                text: input ? "Input" : "Output"
                color: Appearance.colors.white
            }
            StyledText {
                Layout.fillWidth: true
                elide: Text.ElideRight
                font.pixelSize: 12
                text: (input ? Pipewire.defaultAudioSource?.description : Pipewire.defaultAudioSink?.description) ?? "Unknown"
                color: Appearance.colors.extraBrightGrey
            }
        }
    }
}