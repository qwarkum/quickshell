pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.styles
import qs.services

Item {
    id: root

    /* external control */
    property bool shown: false

    readonly property int enterDuration: 300
    readonly property int exitDuration: 350
    readonly property list<real> enterCurve: Appearance.animationCurves.standard
    readonly property list<real> exitCurve: Appearance.animationCurves.standard

    implicitHeight: 0
    implicitWidth: content.implicitWidth

    /* actual visibility is decoupled */
    visible: implicitHeight > 0

    states: [
        State {
            name: "open"
            when: root.shown
            PropertyChanges {
                root.implicitHeight: content.implicitHeight
            }
        },
        State {
            name: "closed"
            when: !root.shown
            PropertyChanges {
                root.implicitHeight: 0
            }
        }
    ]

    transitions: [
        Transition {
            from: "closed"
            to: "open"
            NumberAnimation {
                target: root
                property: "implicitHeight"
                duration: root.enterDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.enterCurve
            }
        },
        Transition {
            from: "open"
            to: "closed"
            NumberAnimation {
                target: root
                property: "implicitHeight"
                duration: root.exitDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.exitCurve
            }
        }
    ]

    Loader {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        sourceComponent: Content {
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
