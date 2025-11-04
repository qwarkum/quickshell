import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.styles
import qs.common.widgets

TabButton {
    id: root
    property string buttonText
    property string buttonIcon
    property bool selected: false
    property int rippleDuration: 1200
    height: buttonBackground.height
    property int tabContentWidth: buttonBackground.width - buttonBackground.radius*2

    property color colBackground: Appearance.colors.moduleBackground
    property color colBackgroundHover: Appearance.colors.darkSecondary
    property color colRipple: Appearance.colors.secondary

    MouseArea {
        anchors.fill: parent
        onPressed: (mouse) => mouse.accepted = false
        cursorShape: Qt.PointingHandCursor
    }

    component RippleAnim: NumberAnimation {
        duration: rippleDuration
        easing.type: Appearance.animation.elementMoveEnter.type
        easing.bezierCurve: Appearance.animationCurves.standardDecel
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: (event) => { 
            const {x,y} = event
            const stateY = buttonBackground.y;
            rippleAnim.x = x;
            rippleAnim.y = y - stateY;

            const dist = (ox,oy) => ox*ox + oy*oy
            const stateEndY = stateY + buttonBackground.height
            rippleAnim.radius = Math.sqrt(Math.max(dist(0, stateY), dist(0, stateEndY), dist(width, stateY), dist(width, stateEndY)))

            rippleFadeAnim.complete();
            rippleAnim.restart();
        }
        onReleased: (event) => {
            root.click() 
            rippleFadeAnim.restart();
        }
    }

    RippleAnim {
        id: rippleFadeAnim
        duration: rippleDuration * 2
        target: ripple
        property: "opacity"
        to: 0
    }

    SequentialAnimation {
        id: rippleAnim
        property real x
        property real y
        property real radius

        PropertyAction { target: ripple; property: "x"; value: rippleAnim.x }
        PropertyAction { target: ripple; property: "y"; value: rippleAnim.y }
        PropertyAction { target: ripple; property: "opacity"; value: 1 }

        ParallelAnimation {
            RippleAnim { target: ripple; properties: "implicitWidth,implicitHeight"; from: 0; to: rippleAnim.radius * 2 }
        }
    }

    background: Rectangle {
        id: buttonBackground
        radius: Appearance.configs.windowRadius
        implicitHeight: 37
        color: root.hovered ? root.colBackgroundHover : root.colBackground
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle { width: buttonBackground.width; height: buttonBackground.height; radius: buttonBackground.radius }
        }

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }

        Item {
            id: ripple
            width: ripple.implicitWidth
            height: ripple.implicitHeight
            opacity: 0
            property real implicitWidth: 0
            property real implicitHeight: 0
            visible: width > 0 && height > 0

            Behavior on opacity {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }

            RadialGradient {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root.colRipple }
                    GradientStop { position: 0.3; color: root.colRipple }
                    GradientStop { position: 0.5 ; color: Qt.rgba(224/255, 224/255, 224/255, 0) }
                }
            }

            transform: Translate { x: -ripple.width / 2; y: -ripple.height / 2 }
        }
    }

    contentItem: Item {
        anchors.centerIn: buttonBackground
        RowLayout {
            anchors.centerIn: parent
            spacing: 0
            
            Loader {
                id: iconLoader
                active: buttonIcon?.length > 0
                sourceComponent: buttonIcon?.length > 0 ? materialSymbolComponent : null
                Layout.rightMargin: 5
            }

            Component {
                id: materialSymbolComponent
                MaterialSymbol {
                    verticalAlignment: Text.AlignVCenter
                    text: buttonIcon
                    iconSize: 24
                    fill: selected ? 1 : 0
                    color: selected ? Appearance.colors.main : Appearance.colors.bright
                    Behavior on color {
                        animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                    }
                }
            }

            StyledText {
                id: buttonTextWidget
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14
                color: selected ? Appearance.colors.main : Appearance.colors.bright
                text: buttonText
                Behavior on color {
                    animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
                }
            }
        }
    }
}
