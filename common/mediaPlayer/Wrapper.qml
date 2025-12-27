pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.styles
import qs.services

Item {
    id: root

    /* external control */
    property bool shown: false
    readonly property bool shouldBeActive: visibilities.mediaPlayer && Config.mediaPlayerOpen

    readonly property int enterDuration: 300
    readonly property int exitDuration: 350
    readonly property list<real> enterCurve: Appearance.animationCurves.standard
    readonly property list<real> exitCurve: Appearance.animationCurves.standard

    implicitHeight: 0
    implicitWidth: content.implicitWidth

    /* actual visibility is decoupled */
    visible: implicitHeight > 0

    onShouldBeActiveChanged: {
        if (shouldBeActive) {
            timer.stop();
        }
    }

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

    function toggle() {
        if (!MprisController.activePlayer) return
        const visibilities = Visibilities.getForActive();
        if (visibilities) {
            visibilities.mediaPlayer = !visibilities.mediaPlayer;
        }
    }

    Timer {
        id: timer

        interval: 1000
        onRunningChanged: {
            if (running && !root.shouldBeActive) {
                content.visible = false;
                content.active = true;
            } else {
                content.active = Qt.binding(() => root.shouldBeActive || root.visible);
                content.visible = true;
            }
        }
    }

    IpcHandler {
        id: mediaHandler
        target: "mediaPlayer"
        function toggle() {
            root.toggle()
        }
    }
    
    Connections {
        target: Config

        function onMediaPlayerOpenChanged() {
            root.toggle();
        }
    }

    Loader {
        id: content
        
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        // anchors.left: parent.left
        // anchors.leftMargin: 300

        visible: false
        active: false
        Component.onCompleted: timer.start()

        sourceComponent: Content {
            shown: root.shown
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
