pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.common.utils
import qs.common.components

Singleton {
    id: root
    property string filePath: Directories.shellConfigPath
    property alias options: configOptionsJsonAdapter
    property bool ready: false

    property bool sessionOpen: false
    property bool sidebarRightOpen: false
    property bool wallpaperSelectorOpen: false
    property bool mediaPlayerOpen: false
    property bool barOpen: true
    property bool launcherOpen: false
    property bool audioOsdOpen: false
    property bool brightnessOsdOpen: false
    property bool sidebarRightControlsOpen: false

    property bool useWallpaperColors: true
    property bool useDarkMode: true
    property bool editMode: false
    property bool wifiConnectMode: false
    property bool wifiConnectionItemExpanded: false

    property bool iconOverlayEnabled: true

    property bool cornersVisible: true
    property bool gameModeToggled: false
    property bool batterySaverToggled: false

    property bool revealKeyboardLayout: true

    JsonAdapter {
        id: configOptionsJsonAdapter

        property JsonObject time: JsonObject {
            property JsonObject pomodoro: JsonObject {
                property string alertSound: ""
                property int breakTime: 300
                property int cyclesBeforeLongBreak: 4
                property int focus: 1500
                property int longBreak: 900
            }
        }

        property JsonObject background: JsonObject {
            property string currentWallpaper: ""
            property string thumbnailPath: ""
            property bool isWallpaperVideo: StringUtil.isFileVideo(Config.options.background.currentWallpaper)
            property bool hideWhenFullscreen: false
            property bool showVideoWallpaperOnLockScreen: true
            property bool stopVideoWallpaperProcessWhenLockScreen: true
            property color defaultColor: '#6200ff'
            property JsonObject parallax: JsonObject {
                property bool vertical: false
                property bool autoVertical: false
                property bool enableWorkspace: true
                property real workspaceZoom: 1.07 // Relative to your screen, not wallpaper size
                property bool enableSidebar: true
                property real widgetsFactor: 1.2
            }
        }

        property JsonObject workSafety: JsonObject {
            property JsonObject enable: JsonObject {
                property bool wallpaper: false
                property bool clipboard: false
            }
            property JsonObject triggerCondition: JsonObject {
                property list<string> networkNameKeywords: ["airport", "cafe", "college", "company", "eduroam", "free", "guest", "public", "school", "university"]
                property list<string> fileKeywords: ["anime", "booru", "ecchi", "hentai", "yande.re", "konachan", "breast", "nipples", "pussy", "nsfw", "spoiler", "girl"]
                property list<string> linkKeywords: ["hentai", "porn", "sukebei", "hitomi.la", "rule34", "gelbooru", "fanbox", "dlsite"]
            }
        }

        property JsonObject launcher: JsonObject {
            property int spacing: 15
            property int searchInputHeight: 45
            property JsonObject list: JsonObject {
                property int spacing: 8
            }
        }

        property JsonObject sidebar: JsonObject {
            property JsonObject quickToggles: JsonObject {
                property string style: "android" // Options: classic, android
                property JsonObject android: JsonObject {
                    property int columns: 5
                    property list<var> toggles: [
                        { type: "network", size: 2 },
                        { type: "bluetooth", size: 2 },
                        { type: "powerSaver", size: 1 },
                        { type: "gameMode", size: 1 },
                        { type: "cloudflareWarp", size: 2 },
                        { type: "powerProfile", size: 2 },
                        { type: "audio", size: 1 },
                        { type: "mic", size: 1 },
                        { type: "notifications", size: 1 },
                        { type: "darkMode", size: 1 },
                        { type: "wallpaperColors", size: 1 }
                    ]
                }
            }
        }

        property JsonObject lock: JsonObject {
            property bool useHyprlock: false
            property bool launchOnStartup: false
            property JsonObject blur: JsonObject {
                property bool enable: true
                property real radius: 30
                property real extraZoom: 1
            }
            property bool centerClock: true
            property bool showLockedText: true
            property JsonObject security: JsonObject {
                property bool unlockKeyring: true
                property bool requirePasswordToPower: false
            }
            property bool materialShapeChars: true
        }

        property JsonObject bar: JsonObject {
            property bool showUnreadCount: true
            property JsonObject autoHide: JsonObject {
                property bool enable: false
                property int hoverRegionWidth: 2
                property bool pushWindows: false
                property JsonObject showWhenPressingSuper: JsonObject {
                    property bool enable: true
                    property int delay: 140
                }
            }
            property bool bottom: false // Instead of top
            property int cornerStyle: 0 // 0: Hug | 1: Float | 2: Plain rectangle
            property bool borderless: false // true for no grouping of items
            property string topLeftIcon: "spark" // Options: "distro" or any icon name in ~/.config/quickshell/ii/assets/icons
            property bool showBackground: true
            property bool verbose: true
            property bool vertical: false
            property JsonObject resources: JsonObject {
                property bool alwaysShowSwap: true
                property bool alwaysShowCpu: true
                property int memoryWarningThreshold: 95
                property int swapWarningThreshold: 85
                property int cpuWarningThreshold: 90
            }
            property list<string> screenList: [] // List of names, like "eDP-1", find out with 'hyprctl monitors' command
            property JsonObject utilButtons: JsonObject {
                property bool showScreenSnip: true
                property bool showColorPicker: false
                property bool showMicToggle: false
                property bool showKeyboardToggle: true
                property bool showDarkModeToggle: true
                property bool showPerformanceProfileToggle: false
            }
            property JsonObject tray: JsonObject {
                property bool monochromeIcons: true
                property bool showItemId: false
                property bool invertPinnedItems: true // Makes the below a whitelist for the tray and blacklist for the pinned area
                property list<string> pinnedItems: [ ]
            }
            property JsonObject workspaces: JsonObject {
                property bool monochromeIcons: true
                property int shown: 10
                property bool showAppIcons: true
                property bool alwaysShowNumbers: false
                property int showNumberDelay: 300 // milliseconds
                property list<string> numberMap: ["1", "2"] // Characters to show instead of numbers on workspace indicator
                property bool useNerdFont: false
            }
        }
    }
}