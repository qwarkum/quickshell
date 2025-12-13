import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.styles

ToolTip {
    id: root
    property string content
    property color tooltipColor: Appearance.colors.brightSecondary
    property bool extraVisibleCondition: true
    property bool alternativeVisibleCondition: false
    property bool internalVisibleCondition: {
        const ans = (extraVisibleCondition && (parent.hovered === undefined || parent?.hovered)) || alternativeVisibleCondition
        return ans
    }
    property bool shouldBeVisible: false
    property bool delayEnabled: false
    verticalPadding: 1
    horizontalPadding: 7
    
    Timer {
        id: closeDelayTimer
        interval: 500
        onTriggered: {
            if (!root.internalVisibleCondition) {
                root.shouldBeVisible = false
            }
        }
    }
    
    onInternalVisibleConditionChanged: {
        if (internalVisibleCondition) {
            shouldBeVisible = true
            closeDelayTimer.stop()
        } else {
            if (delayEnabled) {
                closeDelayTimer.restart()
            } else {
                shouldBeVisible = false
            }
        }
    }
    
    opacity: shouldBeVisible ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    background: null
    
    contentItem: Item {
        id: contentItemBackground
        implicitWidth: tooltipTextObject.width + 2 * root.horizontalPadding
        implicitHeight: tooltipTextObject.height + 2 * root.verticalPadding

        Rectangle {
            id: backgroundRectangle
            anchors.bottom: contentItemBackground.bottom
            anchors.horizontalCenter: contentItemBackground.horizontalCenter
            color: tooltipColor
            radius: Appearance.configs.windowRadius
            width: shouldBeVisible ? (tooltipTextObject.width + 2 * padding) : 0
            height: shouldBeVisible ? (tooltipTextObject.height + 2 * padding) : 0
            clip: true

            Behavior on width {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }
            Behavior on height {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }

            StyledText {
                id: tooltipTextObject
                anchors.centerIn: parent
                text: content
                font.pixelSize: 14
                font.hintingPreference: Font.PreferNoHinting
                color: Appearance.colors.textSecondary
                wrapMode: Text.Wrap
            }
        }   
    }
}