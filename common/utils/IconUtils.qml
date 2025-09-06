// IconUtils.qml
pragma Singleton
import QtQuick
import Qt.labs.folderlistmodel

QtObject {
    id: root

    // Properties
    property string defaultIconsPath: "file:///usr/share/icons/hicolor/scalable/apps/"
    property string missingIconImage: "icon-missing.svg"
    
    // Folder model for icon searching
    property FolderListModel iconFinder: FolderListModel {
        folder: root.defaultIconsPath
        nameFilters: ["*.svg", "*.png"]
        showDirs: false
    }

    // Main function to find icons
    function findIconForApp(appName) {
        var lowerAppName = appName.toLowerCase()
        
        for (var i = 0; i < iconFinder.count; i++) {
            var fileName = iconFinder.get(i, "fileName")
            
            // First check exact matches
            if (fileName === appName + ".svg" || fileName === appName + ".png") {
                return defaultIconsPath + fileName
            }

            // Split filename into parts and check each one
            var nameParts = fileName.split('.')
            for (var j = 0; j < nameParts.length - 1; j++) { // Skip extension (last part)
                var part = nameParts[j].toLowerCase()
                
                // Check if this part matches our app name
                if (part.includes(lowerAppName) || lowerAppName.includes(part)) {
                    return defaultIconsPath + fileName
                }
            }
        }

        return defaultIconsPath + missingIconImage
    }
}