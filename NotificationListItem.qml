import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property var notification

    signal clicked()

    height: 100
    color: {
        if (mouseArea.pressed) return Material.color(Material.Grey, Material.Shade200)
        if (mouseArea.containsMouse) return Material.color(Material.Grey, Material.Shade100)
        if (!notification.isRead) return Material.color(Material.Blue, Material.Shade50)
        return "transparent"
    }

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Material.dividerColor
    }

    // Unread indicator
    Rectangle {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 16
        width: 8
        height: 50
        radius: 4
        color: Material.accent
        visible: !notification.isRead
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: notification.isRead ? 24 : 36
        anchors.rightMargin: 24
        spacing: 16

        // Icon
        Rectangle {
            width: 48
            height: 48
            radius: 24
            color: getIconColor()

            Label {
                anchors.centerIn: parent
                text: getIconEmoji()
                font.pixelSize: 24
            }
        }

        // Content
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Label {
                text: notification.title || ""
                font.pixelSize: 16
                font.weight: notification.isRead ? Font.Normal : Font.Bold
                color: Material.foreground
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Label {
                text: notification.message || ""
                font.pixelSize: 14
                color: Material.hintTextColor
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Label {
                text: notification.relativeTime || ""
                font.pixelSize: 12
                color: Material.hintTextColor
            }
        }

        // Action indicator
        Item {
            width: 24
            height: 24
            visible: notification.actionUrl && notification.actionUrl.length > 0

            Label {
                anchors.centerIn: parent
                text: "›"
                font.pixelSize: 24
                color: Material.hintTextColor
            }
        }
    }

    function getIconColor() {
        var type = notification.type || ""
        if (type === "course_submitted" || type === "course_approved") {
            return Material.color(Material.Blue, Material.Shade100)
        } else if (type === "course_rejected") {
            return Material.color(Material.Red, Material.Shade100)
        } else if (type === "instructor_request" || type === "new_student") {
            return Material.color(Material.Purple, Material.Shade100)
        } else if (type === "transaction") {
            return Material.color(Material.Green, Material.Shade100)
        } else {
            return Material.color(Material.Grey, Material.Shade100)
        }
    }

    function getIconEmoji() {
        var type = notification.type || ""
        if (type === "course_submitted") return "📚"
        else if (type === "course_approved") return "✅"
        else if (type === "course_rejected") return "❌"
        else if (type === "instructor_request") return "👤"
        else if (type === "new_student") return "👥"
        else if (type === "transaction") return "💳"
        else return "🔔"
    }
}


