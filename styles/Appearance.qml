pragma Singleton
import QtQuick
import qs.common.utils

QtObject {
    id: root
    
    readonly property QtObject colors: QtObject {
        // Base colors - reference Theme directly
        property color main: Theme.main
        property color textMain: Theme.textMain
        property color textSecondary: Theme.textSecondary
        property color almostMain: Theme.almostMain
        property color closeToMain: Theme.closeToMain
        // property color blue: Theme.blue
        property color darkUrgent: Theme.darkUrgent
        property color urgent: Theme.urgent
        property color brightUrgent: Theme.brightUrgent
        property color lightUrgent: Theme.lightUrgent
        property color lighterUrgent: Theme.lighterUrgent
        property color extraLightUrgent: Theme.extraLightUrgent
        property color secondaryUrgent: Theme.secondaryUrgent
        property color darkSecondary: Theme.darkSecondary
        property color secondary: Theme.secondary
        property color brightSecondary: Theme.brightSecondary
        property color brighterSecondary: Theme.brighterSecondary
        property color extraBrighterSecondary: Theme.extraBrighterSecondary
        property color bright: Theme.bright
        property color extraBrightSecondary: Theme.extraBrightSecondary

        // Panel - reference Theme
        property color panelBackground: Theme.panelBackground
        property color moduleBackground: Theme.moduleBackground
        property color moduleBorder: Theme.moduleBorder
        property color panelBorder: Theme.panelBorder

        // OSD - reference Theme
        property color osdBackground: Theme.osdBackground
        property color osdBorder: Theme.osdBorder

        // Battery - reference Theme
        property color batteryDefaultOnBackground: Theme.batteryDefaultOnBackground
        property color batteryLowBackground: Theme.batteryLowBackground
        property color batteryLowOnBackground: Theme.batteryLowOnBackground
        property color batteryChargedBackground: Theme.batteryChargedBackground
        property color batteryChargedOnBackground: Theme.batteryChargedOnBackground
        property color batteryChargingBackground: Theme.batteryChargingBackground
        property color batteryChargingOnBackground: Theme.batteryChargingOnBackground

        // Workspace - reference Theme
        property color workspace: Theme.workspace
        property color freeWorkspace: Theme.freeWorkspace
        property color activeWorkspace: Theme.activeWorkspace
        property color emptyWorkspace: Theme.emptyWorkspace
        property color hoverBackgroundColor: Theme.hoverBackgroundColor
        property color hoverBorderColor: Theme.hoverBorderColor
        property color blurBackground: Theme.blurBackground
        property color dialogBlur: Theme.dialogBlur
    }

    readonly property QtObject configs: QtObject {
        property int windowRadius: 10
        property int widgetRadius: 15
        property int toggledRadius: 17
        property int panelRadius: 20
        property int full: 999
        property double windowBorderWidth: 1
        property double panelBorderWidth: 1

        property double moduleHeight: 30

        property int osdWidth: 180
        property int osdHeight: 50
        property int barHeight: 40
        property int sidebarWidth: 500

        property int batteryLowPercentage: 20
        property int batteryCriticalPercentage: 5
        property int batteryFullyChargedPercentage: 90

        property int rightContentModuleWidth: 20
    }

    readonly property QtObject fonts: QtObject {
        property string rubik: "Rubik"
        property string jetbrainsMonoNerd: "JetBrainsMono Nerd Font Mono"
        property string materialSymbolsRounded: "Material Symbols Rounded"
    }

    readonly property QtObject animation: QtObject {
        property QtObject elementMove: QtObject {
            property int duration: animationCurves.expressiveDefaultSpatialDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveDefaultSpatial
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animation.elementMove.type
                    easing.bezierCurve: root.animation.elementMove.bezierCurve
                }
            }
            property Component colorAnimation: Component {
                ColorAnimation {
                    duration: root.animation.elementMove.duration
                    easing.type: root.animation.elementMove.type
                    easing.bezierCurve: root.animation.elementMove.bezierCurve
                }
            }
        }
        property QtObject elementMoveEnter: QtObject {
            property int duration: 400
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasizedDecel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveEnter.duration
                    easing.type: root.animation.elementMoveEnter.type
                    easing.bezierCurve: root.animation.elementMoveEnter.bezierCurve
                }
            }
        }
        property QtObject elementMoveExit: QtObject {
            property int duration: 200
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.emphasizedAccel
            property int velocity: 650
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveExit.duration
                    easing.type: root.animation.elementMoveExit.type
                    easing.bezierCurve: root.animation.elementMoveExit.bezierCurve
                }
            }
        }
        property QtObject elementMoveFast: QtObject {
            property int duration: animationCurves.expressiveEffectsDuration
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveEffects
            property int velocity: 850
            property Component colorAnimation: Component { ColorAnimation {
                duration: root.animation.elementMoveFast.duration
                easing.type: root.animation.elementMoveFast.type
                easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
            }}
            property Component numberAnimation: Component { NumberAnimation {
                    duration: root.animation.elementMoveFast.duration
                    easing.type: root.animation.elementMoveFast.type
                    easing.bezierCurve: root.animation.elementMoveFast.bezierCurve
            }}
        }
        property QtObject clickBounce: QtObject {
            property int duration: 200
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.expressiveFastSpatial
            property int velocity: 850
            property Component numberAnimation: Component { NumberAnimation {
                    duration: root.animation.clickBounce.duration
                    easing.type: root.animation.clickBounce.type
                    easing.bezierCurve: root.animation.clickBounce.bezierCurve
            }}
        }
        property QtObject scroll: QtObject {
            property int duration: 200
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: animationCurves.standardDecel
        }
        property QtObject menuDecel: QtObject {
            property int duration: 350
            property int type: Easing.OutExpo
        }
    }

    readonly property QtObject animationCurves: QtObject {
        readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.90, 1, 1] // Default, 350ms
        readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1] // Default, 500ms
        readonly property list<real> expressiveSlowSpatial: [0.39, 1.29, 0.35, 0.98, 1, 1] // Default, 650ms
        readonly property list<real> expressiveEffects: [0.34, 0.80, 0.34, 1.00, 1, 1] // Default, 200ms
        readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedFirstHalf: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82]
        readonly property list<real> emphasizedLastHalf: [5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
        readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
        readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
        readonly property real expressiveFastSpatialDuration: 350
        readonly property real expressiveDefaultSpatialDuration: 500
        readonly property real expressiveSlowSpatialDuration: 650
        readonly property real expressiveEffectsDuration: 200
    }
}