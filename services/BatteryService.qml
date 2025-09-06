pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs.icons
import qs.styles

Singleton {
    readonly property int criticalPercentage: DefaultStyle.configs.batteryCriticalPercentage
    readonly property int fullyChargedPercentage: DefaultStyle.configs.batteryFullyChargedPercentage

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
        if (BatteryService.isCritical) return DefaultStyle.colors.batteryLowOnBackground
        if (BatteryService.isFullyCharged) return DefaultStyle.colors.batteryChargedOnBackground
        if (BatteryService.isCharging) return DefaultStyle.colors.batteryChargingOnBackground
        return DefaultStyle.colors.white
    }

    function getProgressBackground() {
        if (BatteryService.isCritical) return DefaultStyle.colors.batteryLowBackground
        if (BatteryService.isFullyCharged) return DefaultStyle.colors.batteryChargedBackground
        if (BatteryService.isCharging) return DefaultStyle.colors.batteryChargingBackground
        return DefaultStyle.colors.batteryDefaultOnBackground
    }

    function getBatteryIcon() {
        // if (BatteryService.isFullyCharged) return "battery_status_good"
        if (BatteryService.isCharging || BatteryService.isFullyCharged) return "electric_bolt" // "battery_charging_full" 
        // if (BatteryService.isCritical) return "battery_saver"
        return "battery_full"
    }
}