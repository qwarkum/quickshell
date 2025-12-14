import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common.widgets
import qs.styles

Item {
    id: root
    required property string iconName
    required property double percentage
    property int warningThreshold: 100
    property bool shown: true
    clip: true
    visible: width > 0 && height > 0
    implicitWidth: resourceRowLayout.x < 0 ? 0 : resourceRowLayout.implicitWidth
    implicitHeight: 45
    property bool warning: percentage * 100 >= warningThreshold

    RowLayout {
        id: resourceRowLayout
        spacing: 2
        x: shown ? 0 : -resourceRowLayout.width
        anchors {
            verticalCenter: parent.verticalCenter
        }

        CircularProgress {
            id: resourceCircProg
            Layout.alignment: Qt.AlignVCenter
            lineWidth: 2
            value: percentage == 0 ? 0.001 : percentage
            implicitSize: 26
            colPrimary: root.warning ? Appearance.colors.extraLightUrgent : Appearance.colors.main
            enableAnimation: true

            Item {
                anchors.centerIn: parent
                width: resourceCircProg.implicitSize
                height: resourceCircProg.implicitSize
                
                MaterialSymbol {
                    anchors.centerIn: parent
                    font.weight: Font.DemiBold
                    fill: 1
                    text: iconName
                    iconSize: 16
                    color: Appearance.colors.main
                }
            }
        }

        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: fullPercentageTextMetrics.width
            implicitHeight: percentageText.implicitHeight

            TextMetrics {
                id: fullPercentageTextMetrics
                text: "100"
                font.pixelSize: 12
            }

            StyledText {
                id: percentageText
                anchors.centerIn: parent
                color: Appearance.colors.textMain
                font.pixelSize: 14
                text: `${Math.round(percentage * 100).toString()}`
            }
        }

        Behavior on x {
            animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        enabled: resourceRowLayout.x >= 0 && root.width > 0 && root.visible
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.animation.elementMove.duration
            easing.type: Appearance.animation.elementMove.type
            easing.bezierCurve: Appearance.animation.elementMove.bezierCurve
        }
    }
}
