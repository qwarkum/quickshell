pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool wifi: false
    property bool ethernet: false
    property bool nmRunning: true
    property int updateInterval: 1000
    property string networkName: ""
    property int networkStrength: 0
    
    // Material Symbols icon names based on network status
    property string networkIcon: {
        if (!nmRunning) return "public_off"
        
        if (ethernet) {
            return "lan"
        } else if (wifi) {
            return networkStrength > 80 ? "signal_wifi_4_bar" :
                   networkStrength > 60 ? "network_wifi_3_bar" :
                   networkStrength > 40 ? "network_wifi_2_bar" :
                   networkStrength > 20 ? "network_wifi_1_bar" :
                   "signal_wifi_0_bar"
        } else {
            return "public"
        }
    }

    function update() {
        checkNmRunning()
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

    function checkNmRunning() {
        nmCheck.running = true
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
        id: nmCheck
        command: ["sh", "-c", "systemctl is-active --quiet NetworkManager && echo running || echo stopped"]
        stdout: SplitParser {
            onRead: data => {
                root.nmRunning = data.trim() === "running"
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