import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.UPower
import qs.osd
import qs.styles
import qs.common.widgets
import qs.common.utils

AndroidQuickToggle {
    id: root
    
    property int currentProfile: PowerProfiles.profile
    
    buttonIcon: {
        switch (currentProfile) {
            case PowerProfile.PowerSaver: return "energy_savings_leaf"
            case PowerProfile.Balanced: return "balance"
            case PowerProfile.Performance: return "rocket_launch"
        }
    }
    
    toggled: PowerProfiles.profile != PowerProfile.Balanced
    name: "Power profile"
    statusText: {
        switch (currentProfile) {
            case PowerProfile.PowerSaver: return "Power saver"
            case PowerProfile.Balanced: return "Balanced"
            case PowerProfile.Performance: return "Performance"
        }
    }
    expandedSize: true

    onClicked: {
        // Cycle through profiles: PowerSaver → Balanced → Performance → PowerSaver
        if (currentProfile === PowerProfile.PowerSaver) {
            currentProfile = PowerProfile.Balanced
            PowerProfiles.profile = PowerProfile.Balanced
        } else if (currentProfile === PowerProfile.Balanced) {
            currentProfile = PowerProfile.Performance
            PowerProfiles.profile = PowerProfile.Performance
        } else if (currentProfile === PowerProfile.Performance) {
            currentProfile = PowerProfile.PowerSaver
            PowerProfiles.profile = PowerProfile.PowerSaver
        }
    }

    Component.onCompleted: {
        fetchActiveState.running = true
    }

    // Update currentProfile when PowerProfiles.profile changes externally
    Connections {
        target: PowerProfiles
        function onProfileChanged() {
            currentProfile = PowerProfiles.profile
        }
    }

    Process {
        id: fetchActiveState
        command: ["bash", "-c", `
            case "$(powerprofilesctl get)" in
                "power-saver") echo "0" ;;
                "balanced") echo "1" ;;
                "performance") echo "2" ;;
                *) echo "1" ;;
            esac
        `]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.trim()) {
                    const profile = parseInt(text.trim())
                    currentProfile = profile
                    PowerProfiles.profile = profile
                }
            }
        }
    }
    
    // StyledToolTip {
    //     content: {
    //         switch (currentProfile) {
    //             case PowerProfile.PowerSaver: return "Power Saver"
    //             case PowerProfile.Balanced: return "Balanced"
    //             case PowerProfile.Performance: return "Performance"
    //         }
    //     }
    // }
}