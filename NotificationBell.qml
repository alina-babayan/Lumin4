import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    width: 44
    height: 44

    Component.onCompleted: {
        notificationController.loadRecentNotifications()
        refreshTimer.start()
    }

    Timer {
        id: refreshTimer
        interval: 30000
        running: false
        repeat: true
        onTriggered: notificationController.loadRecentNotifications()
    }

    Rectangle {
        id: bellButton
        anchors.fill: parent
        radius: 22
        color: bellMA.containsMouse ? "#F3F4F6" : "transparent"

        Text {
            anchors.centerIn: parent
            text: "🔔"
            font.pixelSize: 20
        }

        // Unread Badge
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.rightMargin: 6
            anchors.topMargin: 6
            width: 18
            height: 18
            radius: 9
            color: "#EF4444"
            visible: notificationController.unreadCount > 0

            Text {
                anchors.centerIn: parent
                text: notificationController.unreadCount > 9 ? "9+" : notificationController.unreadCount.toString()
                font.pixelSize: 9
                font.weight: Font.Bold
                color: "white"
            }
        }

        MouseArea {
            id: bellMA
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: notificationPopup.visible ? notificationPopup.close() : notificationPopup.open()
        }
    }

    Popup {
        id: notificationPopup
        x: parent.width - width
        y: parent.height + 8
        width: 380
        height: 480
        modal: false
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: "white"
            radius: 12
            border.color: "#E5E7EB"
            border.width: 1

            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 0
                verticalOffset: 4
                radius: 12
                samples: 25
                color: "#20000000"
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // Header
            Rectangle {
                Layout.fillWidth: true
                height: 56
                color: "transparent"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: "Notifications"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: "#18181B"
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        height: 32
                        width: markText.implicitWidth + 16
                        radius: 6
                        color: markMA.containsMouse ? "#EEF2FF" : "transparent"
                        visible: notificationController.unreadCount > 0

                        Text {
                            id: markText
                            anchors.centerIn: parent
                            text: "Mark all as read"
                            font.pixelSize: 12
                            color: "#6366F1"
                        }

                        MouseArea {
                            id: markMA
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: notificationController.markAllAsRead()
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#E5E7EB"
                }
            }

            // Notifications List
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                ColumnLayout {
                    width: parent.width
                    spacing: 0

                    Repeater {
                        model: notificationController.recentNotifications

                        Rectangle {
                            Layout.fillWidth: true
                            height: 76
                            color: {
                                if (itemMA.pressed) return "#E5E7EB"
                                if (itemMA.containsMouse) return "#F9FAFB"
                                if (!modelData.isRead) return "#EEF2FF"
                                return "transparent"
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 1
                                color: "#F3F4F6"
                            }

                            // Unread Indicator
                            Rectangle {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                width: 5
                                height: 36
                                radius: 2.5
                                color: "#6366F1"
                                visible: !modelData.isRead
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: modelData.isRead ? 16 : 24
                                anchors.rightMargin: 16
                                spacing: 10

                                // Icon
                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 18
                                    color: getIconBg(modelData.type)

                                    Text {
                                        anchors.centerIn: parent
                                        text: getIconEmoji(modelData.type)
                                        font.pixelSize: 16
                                    }
                                }

                                // Content
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 3

                                    Text {
                                        text: modelData.title || ""
                                        font.pixelSize: 13
                                        font.weight: modelData.isRead ? Font.Normal : Font.Bold
                                        color: "#18181B"
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 1
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.message || ""
                                        font.pixelSize: 12
                                        color: "#6B7280"
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 2
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: modelData.relativeTime || ""
                                        font.pixelSize: 10
                                        color: "#9CA3AF"
                                    }
                                }
                            }

                            MouseArea {
                                id: itemMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!modelData.isRead) {
                                        notificationController.markAsRead(modelData.id)
                                    }

                                    if (modelData.actionUrl && modelData.actionUrl.length > 0) {
                                        console.log("Navigate to:", modelData.actionUrl)
                                        // Add navigation logic here
                                    }

                                    notificationPopup.close()
                                }
                            }
                        }
                    }
                }

                // Empty State
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 10
                    visible: notificationController.recentNotifications.length === 0

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "🔔"
                        font.pixelSize: 36
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No notifications"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: "#18181B"
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "You're all caught up!"
                        font.pixelSize: 12
                        color: "#9CA3AF"
                    }
                }
            }

            // Footer
            Rectangle {
                Layout.fillWidth: true
                height: 48
                color: "#F9FAFB"

                Rectangle {
                    anchors.top: parent.top
                    width: parent.width
                    height: 1
                    color: "#E5E7EB"
                }

                Rectangle {
                    anchors.centerIn: parent
                    height: 32
                    width: footerText.implicitWidth + 16
                    radius: 6
                    color: footerMA.containsMouse ? "white" : "transparent"

                    Text {
                        id: footerText
                        anchors.centerIn: parent
                        text: "View all notifications"
                        font.pixelSize: 13
                        color: "#6366F1"
                    }

                    MouseArea {
                        id: footerMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            notificationPopup.close()
                            console.log("Navigate to notifications page")
                            // Add navigation to notifications page here
                        }
                    }
                }
            }
        }
    }

    function getIconBg(type) {
        if (type === "course_submitted" || type === "course_approved") return "#EEF2FF"
        if (type === "course_rejected") return "#FEE2E2"
        if (type === "instructor_request" || type === "new_student") return "#FCE7F3"
        if (type === "transaction") return "#DCFCE7"
        return "#F3F4F6"
    }

    function getIconEmoji(type) {
        if (type === "course_submitted") return "📚"
        if (type === "course_approved") return "✅"
        if (type === "course_rejected") return "❌"
        if (type === "instructor_request") return "👨‍🏫"
        if (type === "new_student") return "👤"
        if (type === "transaction") return "💰"
        return "🔔"
    }
}

