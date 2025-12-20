pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.styles

Item {
    id: root

    readonly property real nonAnimHeight: 200
    readonly property int enterDuration: 500
    readonly property int exitDuration: 350
    readonly property list<real> enterCurve: Appearance.animationCurves.expressiveDefaultSpatial // [0.38, 1.21, 0.22, 1, 1, 1]
    readonly property list<real> exitCurve: Appearance.animationCurves.standard // [0.2, 0, 0, 1, 1, 1]

    visible: height > 0
    implicitHeight: 0
    implicitWidth: 600

    states: State {
        name: "visible"
        when: root.visible

        PropertyChanges {
            root.implicitHeight: root.nonAnimHeight
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            NumberAnimation {
                target: root
                property: "implicitHeight"
                duration: root.enterDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.enterCurve
            }
        },
        Transition {
            from: "visible"
            to: ""

            NumberAnimation {
                target: root
                property: "implicitHeight"
                duration: root.exitDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.exitCurve
            }
        }
    ]

    // Solid color content - the background is drawn separately in Backgrounds.qml
    // This is just a placeholder to show the panel area
    Item {
        anchors.fill: parent
        // The actual background with rounded corners is drawn by the ShapePath in Backgrounds.qml
    }
}

