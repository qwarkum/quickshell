pragma Singleton
import QtQuick

QtObject {
    id: root
    
    property bool overviewOpen: false
    property bool superReleaseMightTrigger: false
    property bool screenLocked: false
    property bool screenLockContainsCharacters: false
    property bool screenUnlockFailed: false
}