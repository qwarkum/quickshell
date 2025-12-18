import qs.styles
import qs.services
import qs.common.widgets
import qs.bar.modules
import qs.bar.modules.workspaces
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris

// import qs.modules.ii.verticalBar as Vertical

Item {
    id: rootItem

    property int barSection // 0: left, 1: center, 2: right
    property var list
    required property var modelData
    required property int index
    property var originalIndex: index
    property bool vertical: false

    visible: modelData.id !== "music_player" || Mpris.players.values.length > 0
    implicitWidth: wrapper.implicitWidth
    implicitHeight: wrapper.implicitHeight

    property var compMap: ({ // [horizontal, vertical]
        "workspaces": [workspaceComp],
        "music_player": [musicPlayerComp],
        // "system_monitor": [systemMonitorComp],
        // "clock": [clockComp],
        "date": [dateComp],
        "battery": [batteryComp],
        // "utility_buttons": [utilityButtonsComp],
        // "system_tray": [systemTrayComp],
        // "active_window": [activeWindowComp],
        // "date": [dateCompVert]
    })

    property real startRadius: {
        // Check if immediate previous is hidden music player
        if (originalIndex > 0 && 
            list[originalIndex - 1].id === "music_player" && 
            Mpris.players.values.length === 0) {
            return Appearance.configs.full;
        }
        
        // Original logic
        if (barSection === 0 && originalIndex === 0) return 7;
        if (originalIndex === 0 || list.length === 1) return Appearance.configs.full;
        return 7;
    }

    property real endRadius: {
        // Check if immediate next is hidden music player
        if (originalIndex < list.length - 1 && 
            list[originalIndex + 1].id === "music_player" && 
            Mpris.players.values.length === 0) {
            return Appearance.configs.full;
        }
        
        // Original logic
        if (barSection === 2 && originalIndex === list.length - 1) return 7;
        if (originalIndex === list.length - 1 || list.length === 1) return Appearance.configs.full;
        return 7;
    }

    BarGroup {
        id: wrapper
        vertical: rootItem.vertical
        anchors {
            verticalCenter: root.vertical ? rootItem.verticalCenter : undefined
            horizontalCenter: root.vertical ? undefined : rootItem.horizontalCenter
        }
        
        startRadius: rootItem.startRadius
        endRadius: rootItem.endRadius

        items: Loader {
            active: true
            sourceComponent: rootItem.compMap[modelData.id][vertical ? 1 : 0]
        }
    }
    
    // Component { id: activeWindowCompVert; ActiveWindow { vertical: true } }
    // Component { id: activeWindowComp; ActiveWindow {} }

    // Component { id: systemMonitorComp; Resources {} }
    // Component { id: systemMonitorCompVert; Vertical.Resources {} }

    // Component { id: musicPlayerCompVert; Vertical.VerticalMedia {} }
    Component { id: musicPlayerComp; Media {} }

    // Component { id: utilityButtonsCompVert; UtilButtons { vertical: true } }
    // Component { id: utilityButtonsComp; UtilButtons {} }

    Component { id: batteryComp; Battery {} }
    // Component { id: batteryCompVert; Vertical.BatteryIndicator {} }

    // Component { id: clockCompVert; Vertical.VerticalClockWidget {} }
    // Component { id: clockComp; Clock {} }

    Component { id: dateComp; DateTime {} }

    // Component { id: systemTrayCompVert; SysTray { vertical: true } }
    // Component { id: systemTrayComp; SysTray {} }

    // Component { id: dateCompVert; Vertical.VerticalDateWidget {} }

    Component { id: workspaceComp; Workspaces {} }
}