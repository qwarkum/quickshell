pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    
    Process {
        id: notifier
        
        property string topic: "Hello"
        property string message: "Nothing here ("
        property string urgency: "normal"
        property string appName: "Quickshell"

        command: [
            "notify-send", 
            "-u", urgency,
            "-a", appName,
            topic,
            message
        ]
        
        function sendNotification(topicText, messageText, urgencyLevel, applicationName) {
            if (topicText) topic = topicText
            if (messageText) message = messageText
            if (urgencyLevel) urgency = urgencyLevel
            if (applicationName) appName = applicationName
            
            running = true
        }
    }
}