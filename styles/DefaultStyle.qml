pragma Singleton
import QtQuick

QtObject {
    // ======================
    // COLOR DEFINITIONS
    // ======================
    readonly property QtObject colors: QtObject {

        property color white: "#f0f0f0"
        property color red: "#be4444"
        property color blue: "#7cbed8"
        property color darkGrey: "#333333"
        property color grey: "#494949"
        property color brightGrey: "#808080"
        property color extraBrightGrey: "#a0a0a0"
        
        // Panel
        property color panelBackground: "#141414"
        property color moduleBackground: "#202020"
        // property color moduleBackground: "transparent"
        property color moduleBorder: "transparent"
        property color panelBorder: "transparent"

        // OSD
        property color osdBackground: panelBackground
        property color osdBorder: darkGrey

        // Battery
        property color batteryDefaultOnBackground: grey
        property color batteryLowBackground: "#7c2929"
        property color batteryLowOnBackground: "#ff8585"
        property color batteryChargedBackground: "#3a7c29"
        property color batteryChargedOnBackground: "#b5fd94"
        property color batteryChargingBackground: "#29627c"
        property color batteryChargingOnBackground: "#94e8fd"

        // Workspace
        property color workspace: panelBackground
        // property color workspace: "#2b2b2b"
        property color freeWorkspace: "transparent"
        property color activeWorkspace: "#50f0f0f0"
        // property color activeWorkspace: "#7c585858"
        property color emptyWorkspace: "#616161"
        property color activeWorkspaceBorder: "#8f8f8f"
        property color hoverBackgroundColor: "transparent"
        property color hoverBorderColor: "transparent"
    }

    readonly property QtObject configs: QtObject {
        property int windowRadius: 10
        property int panelRadius: 20
        property double windowBorderWidth: 1
        property double panelBorderWidth: 1

        property double moduleHeight: 30

        property int osdWidth: 180
        property int osdHeight: 50
        property int barHeight: 40

        property int batteryCriticalPercentage: 15
        property int batteryFullyChargedPercentage: 95

        property int rightSidebarModuleWidth: 15
    }

    readonly property QtObject fonts: QtObject {
        property string rubik: "Rubik"
    }
}