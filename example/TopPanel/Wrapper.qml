pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.styles

Item {
    id: root

    readonly property real nonAnimHeight: 200

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
                duration: 500
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.38, 1.21, 0.22, 1, 1, 1]
            }
        },
        Transition {
            from: "visible"
            to: ""

            NumberAnimation {
                target: root
                property: "implicitHeight"
                duration: 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.3, 0, 0.8, 0.15, 1, 1]
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

