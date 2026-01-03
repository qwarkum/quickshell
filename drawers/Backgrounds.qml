import QtQuick
import QtQuick.Shapes
import qs.styles
import qs.osd.audio as AudioOsd
import qs.osd.brightness as BrightnessOsd
import qs.common.mediaPlayer as MediaPlayer
import qs.common.launcher as Launcher
import qs.common.wallpaperSelector as WallpaperSelector
import qs.common.sidebarRight as SidebarRight

Shape {
    id: root

    required property Panels panels

    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    // TopPanel.Background {
    //     wrapper: root.panels.topPanel

    //     // The startX and startY are set relative to the Shape's coordinate system
    //     // Similar to Dashboard: startX is centered minus rounding, startY is at top
    //     startX: (root.width - wrapper.width) / 2 - Appearance.configs.panelRadius
    //     startY: 0
    // }

    AudioOsd.Background {
        wrapper: root.panels.audioOsdPanel

        startX: (root.width - wrapper.width) / 2 - Appearance.configs.panelRadius
        startY: 0
    }
    
    BrightnessOsd.Background {
        wrapper: root.panels.brightnessOsdPanel

        startX: (root.width - wrapper.width) / 2 - Appearance.configs.panelRadius
        startY: 0
    }
    
    MediaPlayer.Background {
        wrapper: root.panels.mediaPlayerPanel

        startX: (root.width - wrapper.width) / 4 - Appearance.configs.panelRadius
        startY: 0
    }

    Launcher.Background {
        wrapper: root.panels.launcherPanel

        startX: (root.width - wrapper.width) / 2 - Appearance.configs.panelRadius
        startY: root.height
    }

    WallpaperSelector.Background {
        wrapper: root.panels.wallpaperSelectorPanel

        startX: (root.width - wrapper.width) / 2 - Appearance.configs.panelRadius
        startY: root.height
    }

    // SidebarRight.Background {
    //     wrapper: root.panels.sidebarRightPanel
    //     panels: root.panels
        
    //     startX: root.width - Appearance.configs.sidebarWidth
    //     startY: (root.height - wrapper.height) / 2 - Appearance.configs.panelRadius
    // }
}

