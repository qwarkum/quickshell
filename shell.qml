import Quickshell
import "./bar"
import "./osd"
import qs.common.widgets
import qs.bar.modules.sidebarRight

Scope {
    LazyLoader {active: true; component: Bar {} }

    LazyLoader {active: true; component: ScreenTopCorners {} }
    LazyLoader {active: true; component: SidebarRight {} }
    LazyLoader {active: true; component: ScreenBottomCorners {} }
    
    LazyLoader {active: true; component: BrightnessOsd {} }
    LazyLoader {active: true; component: AudioOsd {} }

    LazyLoader {active: true; component: WallpaperSelector {} }
    LazyLoader {active: true; component: SessionScreen {} }

}