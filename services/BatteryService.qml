pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.icons
import qs.styles

Singleton {
    readonly property int criticalPercentage: Appearance.configs.batteryCriticalPercentage
    readonly property int fullyChargedPercentage: Appearance.configs.batteryFullyChargedPercentage

    property real percentage: UPower.displayDevice.percentage
    property bool available: UPower.displayDevice.isLaptopBattery
    property var chargeState: UPower.displayDevice.state
    property bool isCharging: chargeState == UPowerDeviceState.Charging
    property bool isCharged: chargeState == UPowerDeviceState.FullyCharged
    property bool isPluggedIn: isCharging || (chargeState == UPowerDeviceState.PendingCharge)
    property bool isCritical: !isCharging && (percentage <= criticalPercentage / 100)
    property bool isFullyCharged: (isCharged || isCharging) && (percentage >= fullyChargedPercentage / 100)

    property color progressColor: getProgressColor()
    property color progressBackground: getProgressBackground()
    property string batteryIcon: getBatteryIcon()

    function getProgressColor() {
        if (BatteryService.isCritical) return Appearance.colors.batteryLowOnBackground
        if (BatteryService.isFullyCharged) return Appearance.colors.batteryChargedOnBackground
        if (BatteryService.isCharging) return Appearance.colors.batteryChargingOnBackground
        return Appearance.colors.main
    }

    function getProgressBackground() {
        if (BatteryService.isCritical) return Appearance.colors.batteryLowBackground
        if (BatteryService.isFullyCharged) return Appearance.colors.batteryChargedBackground
        if (BatteryService.isCharging) return Appearance.colors.batteryChargingBackground
        return Appearance.colors.batteryDefaultOnBackground
    }

    function getBatteryIcon() {
        if (BatteryService.isCritical) return "power"
        // if (BatteryService.isFullyCharged) return "battery_status_good" "battery_android_share"
        if (BatteryService.isCharging) return "bolt" // "battery_android_bolt" // "battery_charging_full" "electric_bolt" 
        if (Config.batterySaverToggled) return "energy_savings_leaf" // "battery_saver"
        return "battery_full" // "battery_android_full"
    }
}