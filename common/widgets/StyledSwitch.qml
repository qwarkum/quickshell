import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import qs.styles

/**
 * Material 3 switch. See https://m3.material.io/components/switch/overview
 */
Switch {
    id: root
    property real scale: 0.6 // Default in m3 spec is huge af
    implicitHeight: 32 * root.scale
    implicitWidth: 52 * root.scale
    property color activeColor: Appearance?.colors.main
    property color inactiveColor: Appearance?.colors.darkSecondary

    MouseArea {
        anchors.fill: parent
        onPressed: (mouse) => mouse.accepted = false
        cursorShape: Qt.PointingHandCursor
    }

    // Custom track styling
    background: Rectangle {
        width: parent.width
        height: parent.height
        radius: Appearance?.configs.full
        color: root.checked ? root.activeColor : root.inactiveColor
        border.width: 2 * root.scale
        border.color: root.checked ? root.activeColor : Appearance.colors.bright

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
        Behavior on border.color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }

    // Custom thumb styling
    indicator: Rectangle {
        width: (root.pressed || root.down) ? (28 * root.scale) : root.checked ? (24 * root.scale) : (16 * root.scale)
        height: (root.pressed || root.down) ? (28 * root.scale) : root.checked ? (24 * root.scale) : (16 * root.scale)
        radius: Appearance.configs.full
        color: root.checked ? Appearance.colors.darkSecondary : Appearance.colors.bright
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: root.checked ? ((root.pressed || root.down) ? (22 * root.scale) : 24 * root.scale) : ((root.pressed || root.down) ? (2 * root.scale) : 8 * root.scale)

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: Appearance.animationCurves.expressiveFastSpatialDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: Appearance.animationCurves.expressiveFastSpatialDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Appearance.animationCurves.expressiveFastSpatialDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animationCurves.expressiveFastSpatial
            }
        }
        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }
}
