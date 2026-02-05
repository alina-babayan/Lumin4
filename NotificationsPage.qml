import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    Component.onCompleted: {
        notificationController.loadNotifications()
    }

    Rectangle {
        anchors.fill: parent
        color: "#FAFAFA"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 24

            // Header
            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 4

                    Text {
                        text: "Notifications"
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                        color: "#18181B"
                    }

                    Text {
                        text: notificationController.unreadCount > 0 ?
                              notificationController.unreadCount + " unread notification" +
                              (notificationController.unreadCount > 1 ? "s" : "") :
                              "All caught up!"
                        font.pixelSize: 13
                        color: "#6B7280"
                    }
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    height: 36
                    width: markAllText.implicitWidth + 24
                    radius: 6
                    color: markAllMA.containsMouse ? "#4F46E5" : "#6366F1"
                    visible: notificationController.unreadCount > 0

                    Text {
                        id: markAllText
                        anchors.centerIn: parent
                        text: "Mark all as read"
                        font.pixelSize: 13
                        color: "white"
                    }

                    MouseArea {
                        id: markAllMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: !notificationController.isLoading
                        onClicked: notificationController.markAllAsRead()
                    }
                }

                Rectangle {
                    height: 36
                    width: refreshText.implicitWidth + 24
                    radius: 6
                    color: refreshMA.containsMouse ? "#F3F4F6" : "white"
                    border.color: "#E5E7EB"
                    border.width: 1

                    Text {
                        id: refreshText
                        anchors.centerIn: parent
                        text: "↻ Refresh"
                        font.pixelSize: 13
                        color: "#6B7280"
                    }

                    MouseArea {
                        id: refreshMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: notificationController.refresh()
                    }
                }
            }

            // Filter Tabs
            Rectangle {
                Layout.fillWidth: true
                height: 56
                radius: 10
                color: "white"
                border.color: "#E5E7EB"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 8

                    Repeater {
                        model: [
                            { label: "All", value: "all" },
                            { label: "Unread", value: "unread", count: notificationController.unreadCount },
                            { label: "Read", value: "read" }
                        ]

                        Rectangle {
                            height: 34
                            width: tabLabel.implicitWidth + 24
                            radius: 6
                            color: {
                                var isActive = notificationController.currentFilter === modelData.value
                                if (isActive) return "#6366F1"
                                if (tabMA.containsMouse) return "#F3F4F6"
                                return "transparent"
                            }

                            Text {
                                id: tabLabel
                                anchors.centerIn: parent
                                text: {
                                    var label = modelData.label
                                    if (modelData.count !== undefined && modelData.count > 0) {
                                        label += " (" + modelData.count + ")"
                                    }
                                    return label
                                }
                                font.pixelSize: 13
                                color: notificationController.currentFilter === modelData.value ? "white" : "#6B7280"
                            }

                            MouseArea {
                                id: tabMA
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notificationController.setFilter(modelData.value)
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }
                }
            }

            // Notifications List
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: "white"
                border.color: "#E5E7EB"
                border.width: 1

                Item {
                    anchors.fill: parent

                    // Loading State
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 16
                        visible: notificationController.isLoading

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "⏳"
                            font.pixelSize: 48
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Loading notifications..."
                            font.pixelSize: 13
                            color: "#9CA3AF"
                        }
                    }

                    // Empty State
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 12
                        visible: !notificationController.isLoading && notificationController.notifications.length === 0

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "🔔"
                            font.pixelSize: 48
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: {
                                if (notificationController.currentFilter === "unread") {
                                    return "No unread notifications"
                                } else if (notificationController.currentFilter === "read") {
                                    return "No read notifications"
                                } else {
                                    return "No notifications"
                                }
                            }
                            font.pixelSize: 15
                            font.weight: Font.Medium
                            color: "#18181B"
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "You're all caught up!"
                            font.pixelSize: 13
                            color: "#9CA3AF"
                        }
                    }

                    // Notifications ScrollView
                    ScrollView {
                        anchors.fill: parent
                        visible: !notificationController.isLoading && notificationController.notifications.length > 0
                        clip: true

                        ColumnLayout {
                            width: parent.parent.width
                            spacing: 0

                            Repeater {
                                model: notificationController.notifications

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 88
                                    color: {
                                        if (rowMA.pressed) return "#E5E7EB"
                                        if (rowMA.containsMouse) return "#F9FAFB"
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
                                        anchors.leftMargin: 16
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 6
                                        height: 44
                                        radius: 3
                                        color: "#6366F1"
                                        visible: !modelData.isRead
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: modelData.isRead ? 24 : 32
                                        anchors.rightMargin: 24
                                        spacing: 14

                                        // Icon
                                        Rectangle {
                                            width: 44
                                            height: 44
                                            radius: 22
                                            color: getIconBg(modelData.type)

                                            Text {
                                                anchors.centerIn: parent
                                                text: getIconEmoji(modelData.type)
                                                font.pixelSize: 20
                                            }
                                        }

                                        // Content
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 4

                                            Text {
                                                text: modelData.title || ""
                                                font.pixelSize: 14
                                                font.weight: modelData.isRead ? Font.Normal : Font.Bold
                                                color: "#18181B"
                                                Layout.fillWidth: true
                                                wrapMode: Text.WordWrap
                                                maximumLineCount: 1
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                text: modelData.message || ""
                                                font.pixelSize: 13
                                                color: "#6B7280"
                                                Layout.fillWidth: true
                                                wrapMode: Text.WordWrap
                                                maximumLineCount: 2
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                text: modelData.relativeTime || ""
                                                font.pixelSize: 11
                                                color: "#9CA3AF"
                                            }
                                        }

                                        // Action Indicator
                                        Item {
                                            width: 20
                                            height: 20
                                            visible: modelData.actionUrl && modelData.actionUrl.length > 0

                                            Text {
                                                anchors.centerIn: parent
                                                text: "›"
                                                font.pixelSize: 20
                                                color: "#9CA3AF"
                                            }
                                        }
                                    }

                                    MouseArea {
                                        id: rowMA
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
                                        }
                                    }
                                }
                            }
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


