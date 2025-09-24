import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "Material Example"

    // 👇 Enable Material style
    Material.theme: Material.Light
    Material.accent: Material.Blue

    Column {
        anchors.centerIn: parent
        spacing: 20

        M3Button {
                    type: M3Button.Style.Elevated
                    text: "Elevated"
                    onClicked: {
                        if (M3Colors.theme == M3Colors.Theme.Dark) {
                            M3Colors.setTheme(M3Colors.Theme.Light);
                        } else {
                            M3Colors.setTheme(M3Colors.Theme.Dark);
                        }
                    }
                }

        // Button {
        //     text: "Click Me"
        // }

        // TextField {
        //     placeholderText: "Enter something"
        // }

        // Switch {
        //     text: "Enable option"
        // }

        // ProgressBar {
        //     indeterminate: true
        // }

        // BusyIndicator {
        //     anchors.centerIn: parent
        //     running: loader.status == Loader.Loading 
        // }
    }
}
