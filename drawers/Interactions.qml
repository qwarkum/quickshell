import QtQuick

Item {
    required property Panels panels
    anchors.fill: parent

    MouseArea {
        anchors.fill: parent
        onClicked: {
            // Hide all OSDs when clicking anywhere
            panels.visibilities.audioOsd = false
            panels.visibilities.brightnessOsd = false
        }
    }
}
