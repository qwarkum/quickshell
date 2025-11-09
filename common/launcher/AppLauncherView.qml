import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.common.components
import qs.common.widgets
import qs.styles

ColumnLayout {
    id: root
    anchors.fill: parent
    spacing: Config.options.launcher.list.spacing

    property alias searchInput: searchInput
    property int visibleItemCount: filteredAppModel.count

    function extractCommandFromEntry(entry) {
        var command = ""
        if (Array.isArray(entry.command) && entry.command.length > 0) command = entry.command[0]
        else if (entry.execString) command = entry.execString
        else if (entry.Exec) command = entry.Exec
        else if (entry.exec) command = entry.exec
        else if (entry.Command) command = entry.Command
        else if (entry.cmd) command = entry.cmd
        return command ? cleanCommand(command) : ""
    }

    function cleanCommand(cmdString) {
        return cmdString.replace(/%[UuFf]/g, '').replace(/\s+/g, ' ').trim()
    }

    function updateFilteredModel() {
        filteredAppModel.clear()
        if (filterText === "") {
            visibleItemCount = 0
            return
        }

        // Dynamic app search
        var results = AppSearch.fuzzyQuery(filterText)
        for (var i = 0; i < results.length; i++) {
            var entry = results[i]
            filteredAppModel.append({
                name: entry.Name || entry.name || entry.DisplayName || entry.displayName || "Unknown",
                cmd: extractCommandFromEntry(entry),
                iconName: AppSearch.guessIcon(entry.Name || entry.name),
                rawEntry: entry
            })
        }

        visibleItemCount = filteredAppModel.count
        if (filteredAppModel.count > 0) appList.currentIndex = 0
    }

    function launchCurrentApp(command: string) {
        // if(command.startsWith('>')) {
        //     var execCommand = command.substring(1)
        //     Quickshell.execDetached(["bash", "-c", execCommand])
        //     console.log(execCommand)
        //     return
        // }
        if (filteredAppModel.count > 0 && appList.currentIndex >= 0) {
            let item = filteredAppModel.get(appList.currentIndex)

            if (!item.cmd) {
                console.log("No command for", item.name)
                return
            }

            const runInTerminal = item.rawEntry.runInTerminal || false
            if (runInTerminal) 
                Quickshell.execDetached(["kitty", item.cmd])
            else 
                Quickshell.execDetached(["bash", "-c", item.cmd])

            Config.launcherOpen = false
        } else {
            Quickshell.execDetached(["bash", "-c", command])
            Config.launcherOpen = false
        }
    }

    StyledListView {
        id: appList
        model: filteredAppModel
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.margins: Config.options.launcher.spacing
        Layout.bottomMargin: 0
        Layout.topMargin: filteredAppModel.count === 0 ? 0 : Config.options.launcher.spacing
        spacing: Config.options.launcher.list.spacing
        highlightFollowsCurrentItem: true
        verticalLayoutDirection: ListView.BottomToTop
        boundsBehavior: Flickable.StopAtBounds
        currentIndex: 0
        clip: true

        Keys.onPressed: (event) => {
            // Navigation keys - handle in list
            if (event.key === Qt.Key_Escape) { 
                Config.launcherOpen = false; 
                event.accepted = true 
            }
            else if (event.key === Qt.Key_Down && currentIndex > 0) { 
                currentIndex--; 
                event.accepted = true 
            }
            else if (event.key === Qt.Key_Up && currentIndex < filteredAppModel.count - 1) { 
                currentIndex++; 
                event.accepted = true 
            }
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { 
                launchCurrentApp(); 
                event.accepted = true 
            }
            // ALL other keys - forward to search input
            else {
                searchInput.searchInput.forceActiveFocus()
                
                // Handle special keys
                if (event.key === Qt.Key_Backspace) {
                    if (searchInput.searchInput.cursorPosition > 0) {
                        searchInput.searchInput.text = searchInput.searchInput.text.slice(0, searchInput.searchInput.cursorPosition - 1) + 
                                                     searchInput.searchInput.text.slice(searchInput.searchInput.cursorPosition)
                        searchInput.searchInput.cursorPosition += 1
                    }
                }
                else if (event.key === Qt.Key_Delete) {
                    if (searchInput.searchInput.cursorPosition < searchInput.searchInput.text.length) {
                        searchInput.searchInput.text = searchInput.searchInput.text.slice(0, searchInput.searchInput.cursorPosition) + 
                                                     searchInput.searchInput.text.slice(searchInput.searchInput.cursorPosition + 1)
                    }
                }
                else if (event.key === Qt.Key_Home) {
                    searchInput.searchInput.cursorPosition = 0
                }
                else if (event.key === Qt.Key_End) {
                    searchInput.searchInput.cursorPosition = searchInput.searchInput.text.length
                }
                else if (event.key === Qt.Key_Left && searchInput.searchInput.cursorPosition > 0) {
                    searchInput.searchInput.cursorPosition -= 1
                }
                else if (event.key === Qt.Key_Right && searchInput.searchInput.cursorPosition < searchInput.searchInput.text.length) {
                    searchInput.searchInput.cursorPosition += 1
                }
                else if (event.text && event.text.length > 0) {
                    searchInput.searchInput.text = searchInput.searchInput.text.slice(0, searchInput.searchInput.cursorPosition) + 
                                                 event.text + searchInput.searchInput.text.slice(searchInput.searchInput.cursorPosition)
                    searchInput.searchInput.cursorPosition += event.text.length
                }
                
                event.accepted = true
            }
        }

        delegate: AppListItem {}
    }

    SearchInput {
        id: searchInput
        Layout.fillWidth: true
        Layout.preferredHeight: Config.options.launcher.searchInputHeight
        Layout.margins: Config.options.launcher.spacing
        Layout.topMargin: 0

        Component.onCompleted: {
            const field = searchInput.searchInput
            field.textChanged.connect(() => {
                filterText = field.text
                updateFilteredModel()
            })
        }
    }
}
