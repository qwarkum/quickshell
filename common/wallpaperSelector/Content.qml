import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.styles
import qs.services
import qs.common.utils
import qs.common.widgets
import qs.common.components

Item {
    id: root
    
    implicitWidth: 1100
    implicitHeight: 680
    property alias searchText: searchBar.text
    property string wallpapersPath: Directories.wallpapers
    property string currentWallpaperPath: Directories.currentWallpaperSymlink
    property string selectedFile: ""
    property bool showVideos: false

    FolderListModel {
        id: folderModel
        folder: Directories.wallpapersNotTrimed
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.webp", "*.mp4", "*.gif"]
        showDirs: false
    }

    Process {
        id: thumbnailGenerator
    }

    Process {
        id: linkProc
        property string fileName: ""
        command: ["ln", "-sf", root.wallpapersPath + "/" + fileName, root.currentWallpaperPath]
        onExited: WallpaperService.updateWallpaper()
    }
    
    // Replaces FolderListModel with a lighter approach
    function isVideo(fileName) {
        return StringUtil.isFileVideo(fileName)
    }

    function getThumbnail(fileName) {
        if (!isVideo(fileName)) return folderModel.get(i, "fileUrl")

        const thumbPath = `${Directories.mpvpaperThumbnails}/${fileName}.jpg`

            thumbnailGenerator.command = ["bash", "-c", `ffmpeg -y -i "${folderModel.folder}/${fileName}" -vframes 1 "${thumbPath}" 2>/dev/null`]
            thumbnailGenerator.running = true

        return "file://" + thumbPath
    }

    property var filteredModel: {
        if (!folderModel.count) return []

        const list = []
        const maxItems = 50

        for (let i = 0; i < Math.min(folderModel.count, maxItems); i++) {
            const f = folderModel.get(i, "fileName")
            const video = isVideo(f)

            // New logic:
            // If showVideos is true, skip images
            // If showVideos is false, skip videos
            if ((root.showVideos && !video) || (!root.showVideos && video)) continue

            // Apply search filter
            if (searchText === "" || f.toLowerCase().includes(searchText.toLowerCase())) {
                list.push({
                    fileName: f,
                    fileUrl: video ? getThumbnail(f) : folderModel.get(i, "fileUrl")
                })
            }
        }

        return list
    }

    function applyWallpaper(fileName) {
        if (!fileName) return
        root.selectedFile = fileName

        linkProc.fileName = fileName
        linkProc.running = true
    }

    function refreshWallpapers() {
        folderModel.folder = ""
        folderModel.folder = Directories.wallpapersNotTrimed
    }

    Item {
        id: container
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 10
                Layout.leftMargin: 20
                Layout.preferredHeight: 40
                spacing: 10

                MaterialSymbol {
                    text: "filter"
                    iconSize: 24
                }

                StyledText {
                    text: "Wallpaper selector"
                    color: Appearance.colors.textMain
                    font {
                        pixelSize: 22
                        weight: Font.DemiBold
                    }
                }
            }

            Rectangle {
                implicitHeight: 1
                color: Appearance.colors.secondary
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 10
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: 0

                        StyledText {
                            text: "Show live wallpapers"
                            font {
                                pixelSize: 18
                                weight: Font.Medium
                            }
                        }
                        StyledText {
                            text: "Show .mp4 .webm .mkv .avi .mov files"
                            font.pixelSize: 16
                            color: Appearance.colors.bright
                        }
                    }

                    Item { Layout.fillWidth: true }
                    
                    StyledSwitch {
                        checked: root.showVideos
                        down: root.down
                        scale: 0.8
                        Layout.fillWidth: false
                        onClicked: { 
                            root.showVideos = checked
                            grid.forceActiveFocus()
                        }
                    }

                    // Item { Layout.fillWidth: true }

                    // StyledText {
                    //     text: "Apply to all monitors"
                    //     font.pixelSize: 18
                    // }
                    // StyledSwitch {
                    //     checked: true
                    //     down: root.down
                    //     scale: 0.8
                    //     Layout.fillWidth: false
                    //     onClicked: { 
                    //         // root.showVideos = checked
                    //         grid.forceActiveFocus()
                    //     }
                    // }
                }
            }

            // wallpaper grid
            WallpaperGrid {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 10
                // Layout.bottomMargin: searchBar.implicitHeight + searchBar.anchors.bottomMargin * 2
                modelData: root.filteredModel

                selectedName: root.selectedFile
                onModelDataChanged: {
                    selectedIndex = 0
                    root.selectedFile = modelData.length > 0 ? modelData[0].fileName : ""
                }

                onWallpaperClicked: (fileName) => {
                    root.selectedFile = fileName
                    root.applyWallpaper(fileName)
                }
            }
        }

        WallpaperToolbar {
            id: searchBar
            // Layout.alignment: Qt.AlignHCenter
            // Layout.preferredWidth: 500
            // Layout.preferredHeight: 45
            // Layout.margins: 15
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 8
            }
        }
    }
}