import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.styles

/**
 * Material 3 progress bar. See https://m3.material.io/components/progress-indicators/overview
 */
ProgressBar {
    id: root
    property real valueBarWidth: 120
    property real valueBarHeight: 4
    property real valueBarGap: 4
    property color highlightColor: Appearance.colors.white
    property color trackColor: Appearance.colors.grey
    property bool sperm: false // If true, the progress bar will have a wavy fill effect
    property bool animateSperm: false
    property real spermAmplitudeMultiplier: sperm ? 0.5 : 0
    property real spermFrequency: 6
    property real spermFps: 60
    
    background: Item {
        anchors.fill: parent
        implicitHeight: valueBarHeight
        implicitWidth: valueBarWidth
    }

    contentItem: Item {
        anchors.fill: parent

        Canvas {
            id: wavyFill
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            height: parent.height * 6
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                var progress = root.visualPosition;
                var fillWidth = progress * width;
                var amplitude = parent.height * root.spermAmplitudeMultiplier;
                var frequency = root.spermFrequency;
                var phase = Date.now() / 400.0;
                var centerY = height / 2;

                ctx.strokeStyle = root.highlightColor;
                ctx.lineWidth = parent.height;
                ctx.lineCap = "round";
                ctx.beginPath();
                
                // Draw the wavy line
                for (var x = ctx.lineWidth / 2; x <= fillWidth - (ctx.lineWidth / 2); x += 1) {
                    var waveY = centerY + amplitude * Math.sin(frequency * 2 * Math.PI * x / width + phase);
                    if (x === ctx.lineWidth / 2)
                        ctx.moveTo(x, waveY);
                    else
                        ctx.lineTo(x, waveY);
                }
                
                // If we're not at the very end, draw the rounded cap
                if (fillWidth > 0 && fillWidth < width) {
                    var endX = Math.min(fillWidth, width - (ctx.lineWidth / 2));
                    var endY = centerY + amplitude * Math.sin(frequency * 2 * Math.PI * endX / width + phase);
                    ctx.lineTo(endX, endY);
                }
                
                ctx.stroke();
            }
            Connections {
                target: root
                function onValueChanged() { wavyFill.requestPaint(); }
                function onHighlightColorChanged() { wavyFill.requestPaint(); }
            }
            Timer {
                interval: 1000 / root.spermFps
                running: root.animateSperm
                repeat: root.sperm
                onTriggered: wavyFill.requestPaint()
            }
        }
        
        // Only show the track and end cap when not full
        Rectangle { // Right remaining part fill
            visible: root.visualPosition < 1
            anchors.right: parent.right
            width: (1 - root.visualPosition) * parent.width - valueBarGap
            height: parent.height
            radius: 9999
            color: root.trackColor
        }
        Rectangle { // Stop point
            visible: root.visualPosition < 1
            anchors.right: parent.right
            width: valueBarGap
            height: valueBarGap
            radius: 9999
            color: root.highlightColor
        }
    }
}