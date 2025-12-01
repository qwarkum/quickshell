import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.common.components
import qs.common.widgets
import qs.styles

Rectangle {
    id: searchContainer
    Layout.fillWidth: true
    Layout.preferredHeight: parent.height
    radius: Appearance.configs.windowRadius
    color: Appearance.colors.moduleBackground

    property alias searchInput: searchInput

    // A safe advanced math expression parser.
    function calculate(expr) {
        let s = expr.toLowerCase().replace(/\s+/g, "");

        // Replace constants
        s = s.replace(/pi/g, Math.PI);
        s = s.replace(/\be\b/g, Math.E);

        // Replace ^ with JS power operator
        s = s.replace(/(\d|\))\s*\^\s*(\d|\()/g, "Math.pow($1,$2)");

        // Functions
        s = s.replace(/sin\(/g, "Math.sin(");
        s = s.replace(/cos\(/g, "Math.cos(");
        s = s.replace(/tan\(/g, "Math.tan(");
        s = s.replace(/asin\(/g, "Math.asin(");
        s = s.replace(/acos\(/g, "Math.acos(");
        s = s.replace(/atan\(/g, "Math.atan(");

        s = s.replace(/sqrt\(/g, "Math.sqrt(");
        s = s.replace(/abs\(/g, "Math.abs(");
        s = s.replace(/round\(/g, "Math.round(");
        s = s.replace(/floor\(/g, "Math.floor(");
        s = s.replace(/ceil\(/g, "Math.ceil(");

        s = s.replace(/log\(/g, "Math.log10(");
        s = s.replace(/ln\(/g, "Math.log(");

        // Degrees support: sin(30deg)
        s = s.replace(/(\d+(\.\d+)?)deg/g, "($1*Math.PI/180)");

        try {
            let result = Function("return (" + s + ")")();

            // Format numbers with commas
            if (typeof result === "number" && isFinite(result)) {
                // Limit decimals to 8 for readability
                let rounded = Math.round(result * 1e8) / 1e8;
                return rounded.toLocaleString();
            }

            return result;
        } catch (e) {
            return "";
        }
    }

    Connections {
        target: Config
        function onLauncherOpenChanged() {
            if (Config.launcherOpen) {
                searchInput.forceActiveFocus()
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 5

        MaterialSymbol {
            text: "search"
            color: Appearance.colors.bright
            iconSize: 20
            Layout.alignment: Qt.AlignVCenter
            leftPadding: 10
        }

        TextField {
            id: searchInput
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            placeholderText: "Search apps, exec commands"
            placeholderTextColor: Appearance.colors.bright
            color: Appearance.colors.main
            selectedTextColor: Appearance.colors.moduleBackground
            selectionColor: Appearance.colors.extraBrightSecondary
            font.pixelSize: 16
            font.family: Appearance.fonts.rubik
            background: Rectangle { color: "transparent" }
            rightPadding: 10

            onAccepted: launchCurrentApp(text)

            onTextChanged: {
                if (filterText === "") {
                    if (appList.currentIndex >= 0 && appList.currentIndex < filteredAppModel.count)
                        window.lastSelectedAppName = filteredAppModel.get(appList.currentIndex).name
                }

                filterText = text
                updateFilteredModel()

                if (filterText === "" && window.lastSelectedAppName !== "") {
                    for (var i = 0; i < filteredAppModel.count; i++) {
                        if (filteredAppModel.get(i).name === window.lastSelectedAppName) {
                            appList.currentIndex = i
                            break
                        }
                    }
                }
            }

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    Config.launcherOpen = false
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Down) {
                    appList.forceActiveFocus()
                    if (appList.currentIndex > 0) appList.currentIndex--
                    event.accepted = true
                } 
                else if (event.key === Qt.Key_Up) {
                    appList.forceActiveFocus()
                    if (appList.currentIndex < filteredAppModel.count - 1) appList.currentIndex++
                    event.accepted = true
                }
                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    event.accepted = false
                }
            }
        }
    }
}