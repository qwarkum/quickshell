pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool wifi: false
    property bool ethernet: false
    property bool wifiEnabled: false
    property bool nmRunning: false
    property int updateInterval: 1000
    property string networkName: ""
    property int networkStrength: 0
    
    // Material Symbols icon names based on network status
    property string networkIcon: {
        if (!nmRunning) return "public"
        
        if (ethernet) {
            return "lan"
        }
        return wifiIcon
    }
    property string wifiIcon: {
        if (wifi) {
            return networkStrength > 80 ? "signal_wifi_4_bar" :
                   networkStrength > 60 ? "network_wifi_3_bar" :
                   networkStrength > 40 ? "network_wifi_2_bar" :
                   networkStrength > 20 ? "network_wifi_1_bar" :
                   "signal_wifi_0_bar"
        }
        if(wifiEnabled) {
            return "signal_wifi_bad"
        }
        return "signal_wifi_off"
    }

    function update() {
        nmCheck.running = true
        wifiStatusProcess.running = true
        if (nmRunning) {
            updateConnectionType.startCheck()
            updateNetworkName.running = true
            updateNetworkStrength.running = true
        } else {
            // NetworkManager not running - set offline state
            wifi = false
            ethernet = false
            networkName = ""
            networkStrength = 0
        }
    }

    function enableWifi(enabled = true): void {
        const cmd = enabled ? "on" : "off";
        enableWifiProc.exec(["nmcli", "radio", "wifi", cmd]);
    }

    function toggleWifi(): void {
        enableWifi(!wifiEnabled);
    }

    Timer {
        interval: 10
        running: true
        repeat: true
        onTriggered: {
            root.update()
            interval = root.updateInterval
        }
    }

    Process {
        id: enableWifiProc
    }

    Process {
        id: nmCheck
        command: ["sh", "-c", "systemctl is-active --quiet NetworkManager && echo running || echo stopped"]
        stdout: SplitParser {
            onRead: data => {
                root.nmRunning = data.trim() === "running"
            }
        }
    }

    Process {
        id: wifiStatusProcess
        command: ["nmcli", "radio", "wifi"]
        Component.onCompleted: running = true
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiEnabled = text.trim() === "enabled";
            }
        }
    }

    Process {
        id: updateConnectionType
        property string buffer
        command: ["sh", "-c", "nmcli -t -f NAME,TYPE,DEVICE c show --active"]
        function startCheck() {
            buffer = ""
            running = true
        }
        stdout: SplitParser {
            onRead: data => {
                updateConnectionType.buffer += data + "\n"
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                const lines = buffer.trim().split('\n')
                let hasEthernet = false
                let hasWifi = false
                lines.forEach(line => {
                    if (line.includes("ethernet"))
                        hasEthernet = true
                    else if (line.includes("wireless"))
                        hasWifi = true
                })
                root.ethernet = hasEthernet
                root.wifi = hasWifi
            }
        }
    }

    Process {
        id: updateNetworkName
        command: ["sh", "-c", "nmcli -t -f NAME c show --active | head -1"]
        stdout: SplitParser {
            onRead: data => {
                root.networkName = data
            }
        }
    }

    Process {
        id: updateNetworkStrength
        command: ["sh", "-c", "nmcli -f IN-USE,SIGNAL,SSID device wifi | awk '/^\*/{if (NR!=1) {print $2}}'"]
        stdout: SplitParser {
            onRead: data => {
                root.networkStrength = parseInt(data)
            }
        }
    }
}