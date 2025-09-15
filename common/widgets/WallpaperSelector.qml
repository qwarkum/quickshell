import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.common.ipcHandlers
import qs.styles

PanelWindow {
    id: wallpaperSelectorPanel

    property real slideProgress: 1
    property bool animationRunning: false

    property string wallpapersPath: "file:///home/qwarkum/pictures/wallpapers/"
    property int currentIndex: 0
    property int visibleItems: 5
    property string searchText: ""
    property bool useCarousel: filteredModel().length > visibleItems - 1
    property int filteredCount: filteredModel().length

    implicitWidth: 1500
    implicitHeight: 310
    color: "transparent"
    visible: false
    focusable: true
    anchors.bottom: true
    exclusiveZone: 0
    WlrLayershell.namespace: "quickshell:wallpaperSelector"
    
    HyprlandFocusGrab {
        id: grab
        windows: [ wallpaperSelectorPanel ]
        active: wallpaperSelectorPanel.visible
        onCleared: () => {
            if (!active) wallpaperSelectorPanel.toggle()
        }
    }

    Component.onCompleted: toggle()

    function refreshWallpapers() {
        folderModel.folder = ""
        folderModel.folder = wallpapersPath
    }

    function applyCurrentWallpaper() {
        if (folderModel.count === 0)
            return

        var url
        if (useCarousel) {
            url = folderModel.get(wallpaperCarousel.currentIndex, "fileUrl")
        } else {
            var fileName = filteredModel()[staticContainer.staticCurrentIndex].fileName
            for (var i = 0; i < folderModel.count; i++) {
                if (folderModel.get(i, "fileName") === fileName) {
                    url = folderModel.get(i, "fileUrl")
                    break
                }
            }
        }

        if (!url)
            return

        applyWallpaperProc.wallpaperPath = url.toString().replace("file://", "")
        applyWallpaperProc.running = true

        applyCurrentWallpaperWallpaperProc.wallpaperPath = url.toString().replace("file://", "")
        applyCurrentWallpaperWallpaperProc.running = true
        toggle()
    }

    function toggle() {
        if (slideProgress > 0) {
            slideProgress = 0
        } else {
            if (!visible) {
                visible = true
            }
            slideProgress = 1
        }
    }

    FolderListModel {
        id: folderModel
        folder: wallpapersPath
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.bmp", "*.webp"]
        showDirs: false
    }

    function filteredModel() {
        var filtered = []
        for (var i = 0; i < folderModel.count; i++) {
            var fileName = folderModel.get(i, "fileName")
            if (searchText === "" || fileName.startsWith(searchText)) {
                filtered.push({
                    "fileUrl": folderModel.get(i, "fileUrl"),
                    "fileName": fileName
                })
            }
        }
        return filtered
    }

    Process {
        id: applyWallpaperProc
        property string wallpaperPath: ""
        command: ["swww", "img", "-t", "fade", wallpaperPath]

        onExited: function(exitCode, exitStatus) {
            console.log("Wallpaper applied:", wallpaperPath, "| exit code:", exitCode)
        }
    }

    Process {
        id: applyCurrentWallpaperWallpaperProc
        property string wallpaperPath: ""
        command: ["cp", wallpaperPath, "/home/qwarkum/pictures/wallpapers/.current"]

        onExited: function(exitCode, exitStatus) {
            console.log("Current wallpaper applied:", wallpaperPath, "| exit code:", exitCode)
        }
    }

    WallpaperSelectorIpcHandler {
        root: wallpaperSelectorPanel
    }

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        anchors.leftMargin: Appearance.configs.panelRadius
        anchors.rightMargin: Appearance.configs.panelRadius
        radius: Appearance.configs.panelRadius
        bottomLeftRadius: 0
        bottomRightRadius: 0
        color: Appearance.colors.panelBackground

        RoundCorner {
            corner: RoundCorner.CornerEnum.BottomRight
            implicitSize: Appearance.configs.panelRadius
            color: Appearance.colors.panelBackground
            anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: -Appearance.configs.panelRadius
            }
        }
        RoundCorner {
            corner: RoundCorner.CornerEnum.BottomLeft
            implicitSize: Appearance.configs.panelRadius
            color: Appearance.colors.panelBackground
            anchors {
                bottom: parent.bottom
                right: parent.right
                rightMargin: -Appearance.configs.panelRadius
            }
        }

        FocusScope {
            id: focusRoot
            anchors.fill: parent
            focus: true

            Keys.onLeftPressed: {
                if (!searchField.activeFocus) {
                    if (useCarousel) {
                        wallpaperCarousel.decrementCurrentIndex()
                    } else if (staticContainer.staticCurrentIndex > 0) {
                        staticContainer.staticCurrentIndex--
                    }
                }
            }
            Keys.onRightPressed: {
                if (!searchField.activeFocus) {
                    if (useCarousel) {
                        wallpaperCarousel.incrementCurrentIndex()
                    } else if (staticContainer.staticCurrentIndex < filteredModel().length - 1) {
                        staticContainer.staticCurrentIndex++
                    }
                }
            }
            Keys.onDownPressed: {
                if (!searchField.activeFocus) {
                    searchField.forceActiveFocus()
                }
            }
            Keys.onReturnPressed: {
                if (searchField.activeFocus) {
                    searchField.focus = false
                    if (useCarousel) {
                        wallpaperCarousel.forceActiveFocus()
                    } else {
                        staticContainer.forceActiveFocus()
                    }
                } else {
                    applyCurrentWallpaper()
                }
            }
            Keys.onEscapePressed: {
                if (searchField.activeFocus) {
                    searchField.text = ""
                    searchField.focus = false
                } else {
                    toggle()
                }
            }

            Item {
                id: galleryRoot
                property int gallerySpacing: 40
                readonly property real thumbWidth: 250

                anchors.fill: parent
                anchors.margins: 2
                anchors.bottomMargin: 15

                Rectangle {
                    id: viewport
                    width: parent.width
                    height: parent.height * 0.82
                    radius: Appearance.configs.panelRadius
                    color: Appearance.colors.panelBackground
                    clip: true

                    PathView {
                        id: wallpaperCarousel
                        anchors.fill: parent
                        model: filteredModel()
                        preferredHighlightBegin: 0.5
                        preferredHighlightEnd: 0.5
                        highlightRangeMode: PathView.StrictlyEnforceRange
                        snapMode: PathView.SnapOneItem
                        focus: useCarousel && !searchField.activeFocus
                        clip: true
                        pathItemCount: Math.min(visibleItems + 2, filteredModel().length)
                        visible: useCarousel

                        Keys.onDownPressed: searchField.forceActiveFocus()

                        path: Path {
                            startX: (viewport.width - (galleryRoot.thumbWidth * (Math.min(visibleItems + 2, filteredModel().length)) + galleryRoot.gallerySpacing * (Math.min(visibleItems + 1, filteredModel().length - 1)))) / 2
                            startY: viewport.height/2
                            PathLine {
                                x: viewport.width - (viewport.width - (galleryRoot.thumbWidth * (Math.min(visibleItems + 2, filteredModel().length)) + galleryRoot.gallerySpacing * (Math.min(visibleItems + 1, filteredModel().length - 1)))) / 2
                                y: viewport.height/2
                            }
                        }

                        delegate: wallpaperDelegate
                        onCurrentIndexChanged: wallpaperSelectorPanel.currentIndex = currentIndex
                    }

                    FocusScope {
                        id: staticContainer
                        anchors.fill: parent
                        visible: !useCarousel
                        focus: !useCarousel && !searchField.activeFocus

                        property int staticCurrentIndex: 0
                        property real startX: (parent.width - (galleryRoot.thumbWidth * filteredCount + galleryRoot.gallerySpacing * (filteredCount - 1))) / 2

                        Keys.onLeftPressed: if (staticCurrentIndex > 0) staticCurrentIndex--
                        Keys.onRightPressed: if (staticCurrentIndex < filteredModel().length - 1) staticCurrentIndex++
                        Keys.onDownPressed: searchField.forceActiveFocus()
                        Keys.onReturnPressed: applyCurrentWallpaper()

                        Repeater {
                            model: filteredModel()

                            delegate: Item {
                                width: galleryRoot.thumbWidth
                                height: width * 9 / 16
                                x: staticContainer.startX + index * (galleryRoot.thumbWidth + galleryRoot.gallerySpacing)
                                y: (viewport.height - height) / 2

                                property bool isCurrent: index === staticContainer.staticCurrentIndex
                                property bool galleryHasFocus: staticContainer.activeFocus

                                Column {
                                    width: parent.width
                                    height: parent.height
                                    spacing: 10

                                    scale: (parent.isCurrent && parent.galleryHasFocus) ? 1.2 : 1.0
                                    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                                    opacity: (parent.isCurrent && parent.galleryHasFocus) ? 1.0 : 0.7
                                    SequentialAnimation on opacity {
                                        NumberAnimation { from: 0; to: (isCurrent && galleryHasFocus) ? 1.0 : 0.7; duration: 100 }
                                    }
                                    
                                    Rectangle {
                                        width: parent.width
                                        height: width * 9 / 16
                                        radius: Appearance.configs.windowRadius
                                        clip: true
                                        color: Appearance.colors.darkGrey

                                        Image {
                                            id: wallpaperImage
                                            anchors.fill: parent
                                            source: modelData.fileUrl
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                            cache: true

                                            layer.enabled: true
                                            layer.effect: OpacityMask {
                                                maskSource: Item {
                                                    width: wallpaperImage.width
                                                    height: wallpaperImage.height
                                                    Rectangle {
                                                        anchors.centerIn: parent
                                                        width: wallpaperImage.width
                                                        height: wallpaperImage.height
                                                        radius: Appearance.configs.windowRadius
                                                    }
                                                }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                staticContainer.staticCurrentIndex = index
                                                applyCurrentWallpaper()
                                            }
                                        }
                                    }

                                    Text {
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                        property string baseName: modelData.fileName.replace(/\.[^/.]+$/, "")
                                        text: baseName.length > 30 ? baseName.slice(0, 28) + "..." : baseName
                                        color: Appearance.colors.white
                                        font.pixelSize: 14
                                        font.family: Appearance.fonts.rubik
                                        opacity: (parent.parent.isCurrent && parent.parent.galleryHasFocus) ? 1.0 : 0.5
                                        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                                    }
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    id: searchRow
                    anchors {
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                    width: parent.width * 0.6
                    height: 40
                    spacing: 8

                    Rectangle {
                        id: searchContainer
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height
                        radius: Appearance.configs.windowRadius
                        color: Appearance.colors.moduleBackground

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 0
                            spacing: 5

                            // Search icon
                            MaterialSymbol {
                                text: "search"
                                color: Appearance.colors.grey
                                iconSize: 20
                                Layout.alignment: Qt.AlignVCenter
                                leftPadding: 10
                            }

                            // Input field
                            TextField {
                                id: searchField
                                placeholderText: "Search wallpapers ..."
                                placeholderTextColor: Appearance.colors.grey
                                color: Appearance.colors.white
                                font.pixelSize: 16
                                font.family: Appearance.fonts.rubik
                                background: Rectangle { color: "transparent" }
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                rightPadding: 10

                                onTextChanged: {
                                    searchText = text
                                    if (wallpaperSelectorPanel.useCarousel) {
                                        wallpaperCarousel.currentIndex = 0
                                    } else {
                                        staticContainer.staticCurrentIndex = 0
                                    }
                                }

                                Keys.onReturnPressed: {
                                    focus = false
                                    if (useCarousel) wallpaperCarousel.forceActiveFocus()
                                    else staticContainer.forceActiveFocus()
                                }
                                Keys.onUpPressed: {
                                    focus = false
                                    if (useCarousel) wallpaperCarousel.forceActiveFocus()
                                    else staticContainer.forceActiveFocus()
                                }
                                Keys.onEscapePressed: {
                                    text = ""
                                    focus = false
                                }
                            }
                        }
                    }

                    Button {
                        id: refreshButton
                        Layout.preferredWidth: parent.height
                        Layout.preferredHeight: parent.height
                        background: Rectangle {
                            color: refreshMouse.containsMouse ? Appearance.colors.darkGrey : Appearance.colors.moduleBackground
                            radius: Appearance.configs.windowRadius

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "refresh"
                                color: refreshMouse.containsMouse ? Appearance.colors.brightGrey : Appearance.colors.grey
                                iconSize: 22

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                    }
                                }
                            }

                            MouseArea {
                                id: refreshMouse
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                            }
                        }
                        onClicked: wallpaperSelectorPanel.refreshWallpapers()
                    }
                }

            }
        }

        transform: Translate { y: panelContainer.height * (1 - slideProgress) }
    }

    Component {
        id: wallpaperDelegate

        Column {
            width: galleryRoot.thumbWidth
            height: width * 9 / 16
            spacing: 10

            property bool isCurrent: PathView.isCurrentItem
            property bool galleryHasFocus: wallpaperCarousel.activeFocus

            scale: (isCurrent && galleryHasFocus) ? 1.2 : 1.0
            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

            opacity: (isCurrent && galleryHasFocus) ? 1.0 : 0.7
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

            Rectangle {
                width: parent.width
                height: width * 9 / 16
                radius: Appearance.configs.windowRadius
                clip: true
                color: Appearance.colors.darkGrey

                Image {
                    id: wallpaperImage
                    anchors.fill: parent
                    source: modelData.fileUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true

                    opacity: 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Item {
                            width: wallpaperImage.width
                            height: wallpaperImage.height
                            Rectangle {
                                anchors.centerIn: parent
                                width: wallpaperImage.width
                                height: wallpaperImage.height
                                radius: Appearance.configs.windowRadius
                            }
                        }
                    }

                    Component.onCompleted: {
                        opacity = 1
                    }
                }


                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        wallpaperCarousel.currentIndex = index
                        applyCurrentWallpaper()
                    }
                }
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                property string baseName: modelData.fileName.replace(/\.[^/.]+$/, "")
                text: baseName.length > 30 ? baseName.slice(0, 28) + "..." : baseName
                color: Appearance.colors.white
                font.pixelSize: 14
                font.family: Appearance.fonts.rubik
                opacity: (parent.isCurrent && parent.galleryHasFocus) ? 1.0 : 0.5
                Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
            }
        }
    }

    Behavior on slideProgress {
        NumberAnimation {
            id: slideAnimation
            duration: 300
            easing.type: Easing.OutCubic
            onRunningChanged: {
                wallpaperSelectorPanel.animationRunning = running
                if (!running && wallpaperSelectorPanel.slideProgress === 0)
                    wallpaperSelectorPanel.visible = false
            }
        }
    }
}
