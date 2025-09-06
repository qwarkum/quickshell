import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common.ipcHandlers
import qs.styles

PanelWindow {
    id: wallpaperChangerPanel

    property real slideProgress: 1
    property bool animationRunning: false

    property string wallpapersPath: "file:///home/qwarkum/pictures/wallpapers/"
    property int currentIndex: 0
    property int visibleItems: 5
    property string searchText: ""
    property bool useCarousel: filteredModel().length > visibleItems - 1
    property int filteredCount: filteredModel().length

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

    implicitWidth: 1500
    implicitHeight: 400
    color: "transparent"
    visible: false
    focusable: true
    anchors.bottom: true
    exclusiveZone: 0

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

    WallpaperChangerIpcHandler {
        root: wallpaperChangerPanel
    }

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        anchors.leftMargin: DefaultStyle.configs.panelRadius
        anchors.rightMargin: DefaultStyle.configs.panelRadius
        radius: DefaultStyle.configs.panelRadius
        bottomLeftRadius: 0
        bottomRightRadius: 0
        color: DefaultStyle.colors.panelBackground

        RoundCorner {
            corner: RoundCorner.CornerEnum.BottomRight
            implicitSize: DefaultStyle.configs.panelRadius
            color: DefaultStyle.colors.panelBackground
            anchors {
                bottom: parent.bottom
                left: parent.left
                leftMargin: -DefaultStyle.configs.panelRadius
            }
        }
        RoundCorner {
            corner: RoundCorner.CornerEnum.BottomLeft
            implicitSize: DefaultStyle.configs.panelRadius
            color: DefaultStyle.colors.panelBackground
            anchors {
                bottom: parent.bottom
                right: parent.right
                rightMargin: -DefaultStyle.configs.panelRadius
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
                anchors.margins: 20

                Rectangle {
                    id: viewport
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height * 0.7
                    color: "transparent"
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
                        onCurrentIndexChanged: wallpaperChangerPanel.currentIndex = currentIndex
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
                                height: width * 9 / 16 + 30
                                x: staticContainer.startX + index * (galleryRoot.thumbWidth + galleryRoot.gallerySpacing)
                                y: (parent.height - height) / 2

                                property bool isCurrent: index === staticContainer.staticCurrentIndex
                                property bool galleryHasFocus: staticContainer.activeFocus

                                Column {
                                    width: parent.width
                                    height: parent.height
                                    spacing: 10

                                    scale: (parent.isCurrent && parent.galleryHasFocus) ? 1.2 : 1.0
                                    Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

                                    opacity: (parent.isCurrent && parent.galleryHasFocus) ? 1.0 : 0.7
                                    Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

                                    Rectangle {
                                        width: parent.width
                                        height: width * 9 / 16
                                        radius: DefaultStyle.configs.windowRadius
                                        clip: true
                                        color: DefaultStyle.colors.darkGrey

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
                                                        radius: DefaultStyle.configs.windowRadius
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
                                        color: DefaultStyle.colors.white
                                        font.pixelSize: 14
                                        font.family: DefaultStyle.fonts.rubik
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
                    width: parent.width * 0.65
                    height: 40
                    spacing: 8

                    // Search box
                    Rectangle {
                        id: searchContainer
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height
                        radius: DefaultStyle.configs.windowRadius
                        color: DefaultStyle.colors.moduleBackground

                        TextField {
                            id: searchField
                            anchors.fill: parent
                            anchors.margins: 7
                            placeholderText: "Search wallpapers ..."
                            placeholderTextColor: DefaultStyle.colors.grey
                            color: DefaultStyle.colors.white
                            font.pixelSize: 16
                            font.family: DefaultStyle.fonts.rubik
                            background: Rectangle { color: "transparent" }

                            onTextChanged: {
                                searchText = text
                                if (wallpaperChangerPanel.useCarousel) {
                                    wallpaperCarousel.currentIndex = 0
                                } else {
                                    staticContainer.staticCurrentIndex = 0
                                }
                            }

                            Keys.onReturnPressed: {
                                focus = false
                                if (useCarousel) {
                                    wallpaperCarousel.forceActiveFocus()
                                } else {
                                    staticContainer.forceActiveFocus()
                                }
                            }
                            Keys.onUpPressed: {
                                focus = false
                                if (useCarousel) {
                                    wallpaperCarousel.forceActiveFocus()
                                } else {
                                    staticContainer.forceActiveFocus()
                                }
                            }
                            Keys.onEscapePressed: {
                                text = ""
                                focus = false
                            }
                        }
                    }

                    Button {
                        id: refreshButton
                        Layout.preferredWidth: parent.height
                        Layout.preferredHeight: parent.height
                        background: Rectangle {
                            color: refreshMouse.containsMouse ? DefaultStyle.colors.darkGrey : DefaultStyle.colors.moduleBackground
                            radius: DefaultStyle.configs.windowRadius

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: "refresh"
                                color: refreshMouse.containsMouse ? DefaultStyle.colors.brightGrey : DefaultStyle.colors.grey
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
                        onClicked: wallpaperChangerPanel.refreshWallpapers()
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
            Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

            opacity: (isCurrent && galleryHasFocus) ? 1.0 : 0.7
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }

            Rectangle {
                width: parent.width
                height: width * 9 / 16
                radius: DefaultStyle.configs.windowRadius
                clip: true
                color: DefaultStyle.colors.darkGrey

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
                                radius: DefaultStyle.configs.windowRadius
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
                color: DefaultStyle.colors.white
                font.pixelSize: 14
                font.family: DefaultStyle.fonts.rubik
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
                wallpaperChangerPanel.animationRunning = running
                if (!running && wallpaperChangerPanel.slideProgress === 0)
                    wallpaperChangerPanel.visible = false
            }
        }
    }
}
