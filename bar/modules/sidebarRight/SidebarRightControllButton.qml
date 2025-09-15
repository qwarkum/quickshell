import QtQuick
import QtQuick.Layouts
import qs.styles
import qs.common.widgets
import qs.icons

ColumnLayout {
    id: buttonRoot
    property alias iconText: icon.text
    property alias labelText: label.text
    property bool isActive: false
    property var onPress: undefined
    property var onButtonPressed: undefined
    signal buttonPressed()
    
    spacing: 6
    Layout.alignment: Qt.AlignHCenter
    Layout.preferredWidth: 55

    Rectangle {
        id: buttonRect
        width: 55
        height: 55
        radius: Appearance.configs.panelRadius

        color: {
            if (flashActive) {
                return Appearance.colors.grey
            }
            if (isActive) {
                return Appearance.colors.white
            }
            if (controllButton.containsMouse) {
                return Appearance.colors.darkGrey
            }
            return "transparent"
        }

        MouseArea {
            id: controllButton
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onPressed: {
                buttonRoot.buttonPressed()
                if (onButtonPressed !== undefined) {
                    onButtonPressed()
                }
            }

            onClicked: {
                flashActive = true
                flashTimer.restart()
                if (onPress !== undefined) {
                    onPress()
                }
            }
        }

        MaterialSymbol {
            id: icon
            anchors.centerIn: parent
            iconSize: 28
            color: isActive ? Appearance.colors.panelBackground : Appearance.colors.white
        }
    }

    Text {
        id: label
        text: ""
        visible: false
        font.pixelSize: 14
        font.family: Appearance.fonts.rubik
        color: Appearance.colors.white
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        maximumLineCount: 2
        Layout.alignment: Qt.AlignHCenter
    }
    
    // Flash effect
    property bool flashActive: false

    Timer {
        id: flashTimer
        interval: 5000  // 5 sec
        repeat: false
        onTriggered: flashActive = false
    }

    // Reset flash instantly whenever isActive changes
    onIsActiveChanged: flashActive = false
    
    // Animation for expanding the button
    function expand() {
        expandAnimation.start()
    }
    
    // Animation for compressing from the left side
    function compressLeft() {
        compressLeftAnimation.start()
    }
    
    // Animation for compressing from the right side
    function compressRight() {
        compressRightAnimation.start()
    }
    
    // Expand animation
    SequentialAnimation {
        id: expandAnimation
        PropertyAnimation {
            target: buttonRect
            property: "Layout.preferredWidth"
            to: 70
            duration: 150
            easing.type: Easing.OutBack
        }
        PropertyAnimation {
            target: buttonRect
            property: "Layout.preferredWidth"
            to: 55
            duration: 200
            easing.type: Easing.OutBack
        }
    }
    
    // Compress from left side animation
    SequentialAnimation {
        id: compressLeftAnimation
        PropertyAnimation {
            target: buttonRect
            property: "Layout.preferredWidth"
            to: 45
            duration: 100
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: buttonRect
            property: "Layout.preferredWidth"
            to: 55
            duration: 150
            easing.type: Easing.OutBack
        }
    }
    
    // Compress from right side animation
    SequentialAnimation {
        id: compressRightAnimation
        PropertyAnimation {
            target: buttonRect
            property: "Layout.preferredWidth"
            to: 45
            duration: 100
            easing.type: Easing.InOutQuad
        }
        PropertyAnimation {
            target: buttonRect
            property: "Layout.preferredWidth"
            to: 55
            duration: 150
            easing.type: Easing.OutBack
        }
    }
}