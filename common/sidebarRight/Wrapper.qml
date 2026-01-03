pragma ComponentBehavior: Bound

import qs.styles
import Quickshell
import QtQuick

Item {
    id: root

    required property var visibilities
    readonly property bool shouldBeActive: visibilities.sidebarRight && Config.sidebarRightOpen

    visible: height > 0
    implicitHeight: 0
    implicitWidth: content.implicitWidth

    onStateChanged: {
        if (state === "visible" && timer.running) {
            timer.triggered();
            timer.stop();
        }
    }

    states: State {
        name: "visible"
        when: root.shouldBeActive

        PropertyChanges {
            root.implicitHeight: content.implicitHeight + 12 * 2
        }
    }

    transitions: [
        Transition {
            from: ""
            to: "visible"

            NumberAnimation {
                target: root
                property: "implicitHeight"
                duration: 300
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animationCurves.standard
            }
        },
        Transition {
            from: "visible"
            to: ""

            NumberAnimation {
                target: root
                property: "implicitHeight"
                duration: 350
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.animationCurves.standard
            }
        }
    ]

    Timer {
        id: timer

        running: true
        interval: 1000
        onTriggered: {
            content.active = Qt.binding(() => root.shouldBeActive || root.visible);
            content.visible = true;
        }
    }

    Loader {
        id: content

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 12

        visible: false
        active: false

        sourceComponent: Content {}
    }
}
