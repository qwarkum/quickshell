import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.styles

/**
 * Material 3 slider. See https://m3.material.io/components/sliders/overview
 * It doesn't exactly match the spec because it does not make sense to have stuff on a computer that fucking huge.
 * Should be at 3/4 scale...
 */
 
Slider {
    id: root

    property list<real> stopIndicatorValues: [1]
    enum Configuration {
        XXS = 6,
        XS = 12,
        S = 22,
        M = 30,
        L = 42,
        XL = 72
    }

    property var configuration: StyledSlider.Configuration.XXS

    property bool toolTipVisible: false

    property real handleDefaultWidth: 3
    property real handlePressedWidth: 1.5

    property color highlightColor: Appearance.colors.white
    property color trackColor: Appearance.colors.grey
    property color handleColor: Appearance.colors.white
    property color dotColor: Appearance.colors.grey
    property color dotColorHighlighted: Appearance.colors.white
    property real unsharpenRadius: configuration / 7
    property real trackWidth: configuration
    property real trackRadius: trackWidth >= StyledSlider.Configuration.XL ? 21
        : trackWidth >= StyledSlider.Configuration.L ? 12
        : trackWidth >= StyledSlider.Configuration.M ? 9
        : 6
    property real handleHeight: Math.max(33, trackWidth + 9)
    property real handleWidth: root.pressed ? handlePressedWidth : handleDefaultWidth
    property real handleMargins: 4
    onHandleMarginsChanged: {
        console.log("Handle margins changed to", handleMargins);
    }
    property real trackDotSize: 3
    property string tooltipContent: `${Math.round(value * 100)}%`

    leftPadding: handleMargins
    rightPadding: handleMargins
    property real effectiveDraggingWidth: width - leftPadding - rightPadding

    Layout.fillWidth: true
    from: 0
    to: 1

    Behavior on value { // This makes the adjusted value (like volume) shift smoothly
        SmoothedAnimation {
            velocity: 850
        }
    }

    component TrackDot: Rectangle {
        required property real value
        anchors.verticalCenter: parent.verticalCenter
        x: root.handleMargins + (value * root.effectiveDraggingWidth) - (root.trackDotSize)
        width: root.trackDotSize
        height: root.trackDotSize
        radius: 100
        color: configuration < StyledSlider.Configuration.XS ? root.dotColor : root.dotColorHighlighted
    }

    MouseArea {
        anchors.fill: parent
        onPressed: (mouse) => mouse.accepted = false
        cursorShape: root.pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor 
    }

    background: Item {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        implicitHeight: trackWidth
        
        // Fill left
        Rectangle {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            width: root.handleMargins + (root.visualPosition * root.effectiveDraggingWidth) - (root.handleWidth / 2 + root.handleMargins)
            height: trackWidth
            color: root.highlightColor
            topLeftRadius: root.trackRadius
            bottomLeftRadius: root.trackRadius
            topRightRadius: root.unsharpenRadius
            bottomRightRadius: root.unsharpenRadius
        }

        // Fill right
        Rectangle {
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }
            width: root.handleMargins + ((1 - root.visualPosition) * root.effectiveDraggingWidth) - (root.handleWidth / 2 + root.handleMargins)
            height: trackWidth
            color: root.trackColor
            topRightRadius: root.trackRadius
            bottomRightRadius: root.trackRadius
            topLeftRadius: root.unsharpenRadius
            bottomLeftRadius: root.unsharpenRadius
        }

        // Stop indicators
        Repeater {
            model: root.stopIndicatorValues
            TrackDot {
                required property real modelData
                value: modelData
                anchors.verticalCenter: parent.verticalCenter
                visible: root.value < 0.98
            }
        }
    }

    handle: Rectangle {
        id: handle

        implicitWidth: root.handleWidth
        implicitHeight: root.handleHeight
        x: root.handleMargins + (root.visualPosition * root.effectiveDraggingWidth) - (root.handleWidth / 2)
        anchors.verticalCenter: parent.verticalCenter
        radius: 100
        color: root.handleColor

        StyledToolTip {
            visible: toolTipVisible
            extraVisibleCondition: root.pressed
            content: root.tooltipContent
        }
    }
}