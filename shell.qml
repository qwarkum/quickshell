//@ pragma UseQApplication

import Quickshell
import "./bar"
import "./osd"
import qs.common.wallpaperSelector
import qs.common.sessionScreen
import qs.common.sidebarRight
import qs.common.mediaPlayer
import qs.common.background
import qs.common.launcher
import qs.common.overview
import qs.common.widgets
import qs.common.lock
import qs.notificationPopup

Scope {
    LazyLoader {active: true; component: Background {} }
    LazyLoader {active: true; component: Bar {} }

    LazyLoader {active: true; component: ScreenTopCorners {} }
    LazyLoader {active: true; component: SidebarRight {} }
    LazyLoader {active: true; component: ScreenBottomCorners {} }
    
    LazyLoader {active: true; component: BrightnessOsd {} }
    LazyLoader {active: true; component: AudioOsd {} }

    LazyLoader {active: true; component: MediaPlayer {} }
    LazyLoader {active: true; component: WallpaperSelector {} }
    LazyLoader {active: true; component: SessionScreen {} }

    LazyLoader { active: true; component: NotificationPopup {} }
    LazyLoader { active: true; component: Overview {} }

    LazyLoader { active: true; component: AppLauncher {} }

    LazyLoader { active: true; component: Lock {} }

    // LazyLoader { active: true; component: ReloadPopup {} }
}