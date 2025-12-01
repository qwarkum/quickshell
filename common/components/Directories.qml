pragma Singleton
pragma ComponentBehavior: Bound

import Qt.labs.platform
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    // XDG Dirs, with "file://"
    readonly property string home: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
    readonly property string config: StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0]
    readonly property string state: StandardPaths.standardLocations(StandardPaths.StateLocation)[0]
    readonly property string cache: StandardPaths.standardLocations(StandardPaths.CacheLocation)[0]
    readonly property string genericCache: StandardPaths.standardLocations(StandardPaths.GenericCacheLocation)[0]
    readonly property string documents: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
    readonly property string downloads: StandardPaths.standardLocations(StandardPaths.DownloadLocation)[0]
    readonly property string pictures: StandardPaths.standardLocations(StandardPaths.PicturesLocation)[0]
    readonly property string music: StandardPaths.standardLocations(StandardPaths.MusicLocation)[0]
    readonly property string videos: StandardPaths.standardLocations(StandardPaths.MoviesLocation)[0]
    
    property string scriptPath: Quickshell.shellPath("scripts")
    readonly property string todoPath: trimFileProtocol(`${Directories.state}/user/todo.json`)
    readonly property string shellConfigName: "config.json"
    readonly property string shellConfigPath: `${Directories.shellConfig}/${Directories.shellConfigName}`
    
    readonly property string wallpapersNotTrimed: `${Directories.pictures}/wallpapers`
    readonly property string wallpapers: trimFileProtocol(`${Directories.pictures}/wallpapers`)
    readonly property string mpvpaperThumbnails: trimFileProtocol(`${Directories.cache}/mpvpaper/thumbnails`)
    readonly property string currentWallpaperSymlink: trimFileProtocol(`${Directories.pictures}/wallpapers/.current`)
    readonly property string notificationsPath: trimFileProtocol(`${Directories.cache}/notifications/notifications.json`)
    readonly property string pywalJsonPath: trimFileProtocol(`${Directories.genericCache}/wal/colors.json`)
    readonly property string matugenJsonPath: trimFileProtocol(`${Directories.cache}/matugen/colors.json`)
    readonly property string matugenConfigDir: trimFileProtocol(`${Directories.config}/matugen`)

    function trimFileProtocol(str) {
        return str.startsWith("file://") ? str.slice(7) : str;
    }
}