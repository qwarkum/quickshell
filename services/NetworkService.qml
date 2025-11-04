pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import qs.services.network

Singleton {
    id: root

    property bool wifi: false
    property bool ethernet: false
    property bool wifiEnabled: false
    property bool nmRunning: false
    property int updateInterval: 1000
    property string ipAddress: ""  // Add this property
    property string networkName: ""
    property int networkStrength: 0
    property bool wifiScanning: false
    property bool wifiConnecting: connectProc.running
    property WifiAccessPoint wifiConnectTarget
    readonly property list<WifiAccessPoint> wifiNetworks: []
    readonly property WifiAccessPoint active: wifiNetworks.find(n => n.active) ?? null
    
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
            return networkStrength > 83 ? "signal_wifi_4_bar" :
                   networkStrength > 67 ? "network_wifi" :
                   networkStrength > 50 ? "network_wifi_3_bar" :
                   networkStrength > 33 ? "network_wifi_2_bar" :
                   networkStrength > 17 ? "network_wifi_1_bar" :
                   "signal_wifi_0_bar"
        }
        if(wifiEnabled) {
            return "wifi_find"
        }
        return "signal_wifi_off"
    }

    function update() {
        nmCheck.running = true
        wifiStatusProcess.running = true
        updateConnectionType.startCheck();
        wifiStatusProcess.running = true
        updateNetworkName.running = true;
        updateNetworkStrength.running = true;
        updateIpAddress.running = true;
    }

    function enableWifi(enabled = true): void {
        const cmd = enabled ? "on" : "off";
        enableWifiProc.exec(["nmcli", "radio", "wifi", cmd]);
    }

    function toggleWifi(): void {
        enableWifi(!wifiEnabled);
    }

    function rescanWifi(): void {
        wifiScanning = true;
        rescanProcess.running = true;
    }

    function connectToWifiNetwork(accessPoint: WifiAccessPoint): void {
        accessPoint.askingPassword = false;
        root.wifiConnectTarget = accessPoint;
        // We use this instead of `nmcli connection up SSID` because this also creates a connection profile
        connectProc.exec(["nmcli", "dev", "wifi", "connect", accessPoint.ssid])
    }

    function disconnectWifiNetwork(): void {
        if (active) disconnectProc.exec(["nmcli", "connection", "down", active.ssid]);
    }

    function deleteWifiNetwork(): void {
        if (active) disconnectProc.exec(["nmcli", "connection", "delete", active.ssid]);
    }

    function changePassword(network: WifiAccessPoint, password: string, username = ""): void {
        // TODO: enterprise wifi with username
        network.askingPassword = false;
        changePasswordProc.exec({
            "environment": {
                "PASSWORD": password
            },
            "command": ["bash", "-c", `nmcli connection modify ${network.ssid} wifi-sec.psk "$PASSWORD"`]
        })
    }

    // Timer {
    //     interval: 10
    //     running: true
    //     repeat: true
    //     onTriggered: {
    //         root.update()
    //         interval = root.updateInterval
    //     }
    // }

    Process {
        id: subscriber
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: {
                root.update()
            }
        }
    }

    Process {
        id: enableWifiProc
    }

    Process {
        id: connectProc
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        stdout: SplitParser {
            onRead: line => {
                // print(line)
                getNetworks.running = true
            }
        }
        stderr: SplitParser {
            onRead: line => {
                // print("err:", line)
                if (line.includes("Secrets were required")) {
                    root.wifiConnectTarget.askingPassword = true
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            root.wifiConnectTarget.askingPassword = (exitCode !== 0)
            root.wifiConnectTarget = null
        }
    }

    Process {
        id: disconnectProc
        stdout: SplitParser {
            onRead: getNetworks.running = true
        }
    }

    Process {
        id: changePasswordProc
        onExited: { // Re-attempt connection after changing password
            connectProc.running = false
            connectProc.running = true
        }
    }

    Process {
        id: rescanProcess
        command: ["nmcli", "dev", "wifi", "list", "--rescan", "yes"]
        stdout: SplitParser {
            onRead: {
                wifiScanning = false;
                getNetworks.running = true;
            }
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

    Process {
        id: updateIpAddress
        command: ["sh", "-c", "ip -4 addr show | grep -E 'inet.*scope global' | awk '{print $2}' | head -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const ip = text.trim();
                if (ip) {
                    root.ipAddress = ip;
                    console.log("Current IP address:", ip);
                } else {
                    root.ipAddress = "Not connected";
                    console.log("No IP address found");
                }
            }
        }
    }

    Process {
        id: getNetworks
        running: true
        command: ["nmcli", "-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY", "d", "w"]
        environment: ({
            LANG: "C",
            LC_ALL: "C"
        })
        stdout: StdioCollector {
            onStreamFinished: {
                const PLACEHOLDER = "STRINGWHICHHOPEFULLYWONTBEUSED";
                const rep = new RegExp("\\\\:", "g");
                const rep2 = new RegExp(PLACEHOLDER, "g");

                const allNetworks = text.trim().split("\n").map(n => {
                    const net = n.replace(rep, PLACEHOLDER).split(":");
                    return {
                        active: net[0] === "yes",
                        strength: parseInt(net[1]),
                        frequency: parseInt(net[2]),
                        ssid: net[3],
                        bssid: net[4]?.replace(rep2, ":") ?? "",
                        security: net[5] || ""
                    };
                }).filter(n => n.ssid && n.ssid.length > 0);

                // Group networks by SSID and prioritize connected ones
                const networkMap = new Map();
                for (const network of allNetworks) {
                    const existing = networkMap.get(network.ssid);
                    if (!existing) {
                        networkMap.set(network.ssid, network);
                    } else {
                        // Prioritize active/connected networks
                        if (network.active && !existing.active) {
                            networkMap.set(network.ssid, network);
                        } else if (!network.active && !existing.active) {
                            // If both are inactive, keep the one with better signal
                            if (network.strength > existing.strength) {
                                networkMap.set(network.ssid, network);
                            }
                        }
                        // If existing is active and new is not, keep existing
                    }
                }

                const wifiNetworks = Array.from(networkMap.values());

                const rNetworks = root.wifiNetworks;

                const destroyed = rNetworks.filter(rn => !wifiNetworks.find(n => n.frequency === rn.frequency && n.ssid === rn.ssid && n.bssid === rn.bssid));
                for (const network of destroyed)
                    rNetworks.splice(rNetworks.indexOf(network), 1).forEach(n => n.destroy());

                for (const network of wifiNetworks) {
                    const match = rNetworks.find(n => n.frequency === network.frequency && n.ssid === network.ssid && n.bssid === network.bssid);
                    if (match) {
                        match.lastIpcObject = network;
                    } else {
                        rNetworks.push(apComp.createObject(root, {
                            lastIpcObject: network
                        }));
                    }
                }
            }
        }
    }

    Component {
        id: apComp

        WifiAccessPoint {}
    }
}