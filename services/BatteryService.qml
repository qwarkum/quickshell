pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.icons
import qs.styles

Singleton {
    id: root

    readonly property int lowPercentage: Appearance.configs.batteryLowPercentage
    readonly property int criticalPercentage: Appearance.configs.batteryCriticalPercentage
    readonly property int fullyChargedPercentage: Appearance.configs.batteryFullyChargedPercentage

    property real percentage: UPower.displayDevice.percentage
    property bool available: UPower.displayDevice.isLaptopBattery
    property var chargeState: UPower.displayDevice.state
    property bool isCharging: chargeState == UPowerDeviceState.Charging
    property bool isCharged: chargeState == UPowerDeviceState.FullyCharged
    property bool isPluggedIn: isCharging || (chargeState == UPowerDeviceState.PendingCharge)
    property bool isLow: available && (percentage <= lowPercentage / 100)
    property bool isCritical: available && (percentage <= criticalPercentage / 100)
    property bool isFullyCharged: (isCharged || isCharging) && (percentage >= fullyChargedPercentage / 100)

    property bool isLowAndNotCharging: isLow && !isCharging
    property bool isCriticalAndNotCharging: isCritical && !isCharging

    property color progressColor: getProgressColor()
    property color progressBackground: getProgressBackground()
    property string batteryIcon: getBatteryIcon()

    onIsLowAndNotChargingChanged: {
        if (!root.available || !isLowAndNotCharging) return;
        Quickshell.execDetached([
            "notify-send", 
            "Low battery",
            "Consider plugging in your device",
            "-u", "critical",
            "-a", "Shell",
            "--hint=int:transient:1",
        ])
    }

    onIsCriticalAndNotChargingChanged: {
        if (!root.available || !isCriticalAndNotCharging) return;
        Quickshell.execDetached([
            "notify-send", 
            "Critically low battery",
            "Please charge!",
            "-u", "critical",
            "-a", "Shell",
            "--hint=int:transient:1",
        ]);
    }

    onIsFullyChargedChanged: {
        if (!root.available || !isFullyCharged) return;
        Quickshell.execDetached([
            "notify-send",
            "Battery full",
            "Please unplug the charger",
            "-a", "Shell",
            "--hint=int:transient:1",
        ]);
    }

    function getProgressColor() {
        if (BatteryService.isLowAndNotCharging || BatteryService.isCriticalAndNotCharging) return Appearance.colors.batteryLowOnBackground
        if (BatteryService.isFullyCharged) return Appearance.colors.batteryChargedOnBackground
        if (BatteryService.isCharging) return Appearance.colors.batteryChargingOnBackground
        return Appearance.colors.main
    }

    function getProgressBackground() {
        if (BatteryService.isLowAndNotCharging || BatteryService.isCriticalAndNotCharging) return Appearance.colors.batteryLowBackground
        if (BatteryService.isFullyCharged) return Appearance.colors.batteryChargedBackground
        if (BatteryService.isCharging) return Appearance.colors.batteryChargingBackground
        return Appearance.colors.batteryDefaultOnBackground
    }

    function getBatteryIcon() {
        if (BatteryService.isLowAndNotCharging || BatteryService.isCriticalAndNotCharging) return "power"
        // if (BatteryService.isFullyCharged) return "battery_status_good" "battery_android_share"
        if (BatteryService.isCharging) return "electric_bolt" // "battery_android_bolt" // "battery_charging_full" "electric_bolt" 
        if (Config.batterySaverToggled) return "energy_savings_leaf" // "battery_saver"
        return "battery_full" // "battery_android_full"
    }
}