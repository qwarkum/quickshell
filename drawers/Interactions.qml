import QtQuick

Item {
    required property Panels panels
    anchors.fill: parent

    MouseArea {
        anchors.fill: parent
        onClicked: panels.topPanelVisible = false
    }
}
