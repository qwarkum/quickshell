pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Provides formatted device uptime.
 */
Singleton {
    property string uptime: "0m"

    property string time: Qt.formatDateTime(clock.date, "hh:mm:ss")
    property string timeNoSeconds: Qt.formatDateTime(clock.date, "h:mm")
    property string date: Qt.formatDateTime(clock.date, "dddd, dd.MM")
    property string dateMonthName: Qt.formatDateTime(clock.date, "dddd, dd MMMM")
    property string calendarDate: Qt.formatDateTime(clock.date, "dd MMMM, yyyy")
    
    function sleep(delayTime,cb) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Timer {
        id: timer
    }

    Timer {
        interval: 10
        running: true
        repeat: true
        onTriggered: {
            fileUptime.reload()
            const textUptime = fileUptime.text()
            const uptimeSeconds = Number(textUptime.split(" ")[0] ?? 0)

            // Convert seconds to days, hours, and minutes
            const days = Math.floor(uptimeSeconds / 86400)
            const hours = Math.floor((uptimeSeconds % 86400) / 3600)
            const minutes = Math.floor((uptimeSeconds % 3600) / 60)

            // Build formatted uptime string
            let formatted = ""
            if (days > 0) formatted += `${days}d`
            if (hours > 0) formatted += `${formatted ? " " : ""}${hours}h`
            if (minutes > 0 || !formatted) formatted += `${formatted ? " " : ""}${minutes}m`

            uptime = formatted

            interval = 60000 // 1 minute
        }
    }

    FileView {
        id: fileUptime
        path: "/proc/uptime"
    }
}
