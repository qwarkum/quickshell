pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.styles
import qs.services

Item {
    id: root

    property int contentHeight

    required property ShellScreen screen
    required property PersistentProperties visibilities
    required property var panels
    
    readonly property bool shouldBeActive: visibilities.launcher && true
    readonly property real maxHeight: {
        let max = screen.height - 4;
        if (visibilities.launcher)
            max -= 50;
        return max;
    }

    // onMaxHeightChanged: timer.start()

    visible: height > 0
    implicitHeight: 0
    implicitWidth: content.implicitWidth

    onShouldBeActiveChanged: {
        if (shouldBeActive) {
            timer.stop();
            hideAnim.stop();
            showAnim.start();
        } else {
            showAnim.stop();
            hideAnim.start();
        }
    }

    SequentialAnimation {
        id: showAnim

        NumberAnimation {
            target: root
            property: "implicitHeight"
            to: root.contentHeight
            duration: Appearance.animationCurves.standardDuration
            easing.bezierCurve: Appearance.animationCurves.standard
            easing.type: Easing.BezierSpline
        }
        ScriptAction {
            script: root.implicitHeight = Qt.binding(() => content.implicitHeight)
        }
    }

    SequentialAnimation {
        id: hideAnim

        ScriptAction {
            script: root.implicitHeight = root.implicitHeight
        }
        NumberAnimation {
            target: root
            property: "implicitHeight"
            to: 0
            duration: 350
            easing.bezierCurve: Appearance.animationCurves.standard
            easing.type: Easing.BezierSpline
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
                root.contentHeight = Math.min(root.maxHeight, content.implicitHeight);
                content.active = Qt.binding(() => root.shouldBeActive || root.visible);
                content.visible = true;
                if (showAnim.running) {
                    showAnim.stop();
                    showAnim.start();
                }
            }
        }
    }

    Loader {
        id: content
        
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        // anchors.left: parent.left
        // anchors.leftMargin: 300

        visible: false
        active: false
        Component.onCompleted: timer.start()

        sourceComponent: Content {
            visibilities: root.visibilities
            panels: root.panels
            maxHeight: root.maxHeight

            Component.onCompleted: root.contentHeight = implicitHeight
        }
    }
}
